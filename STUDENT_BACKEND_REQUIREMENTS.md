# Student App Flow - Backend Changes & Technical Requirements

This document outlines all backend fixes, entity updates, TypeORM schemas, DTO validations, and API requirements identified from the QA testing feedback document for the **Student Flow**.

---

## Executive Summary & Status Matrix

| # | Feedback Area | Mobile (Flutter) Status | Backend Action Required | Priority |
|---|---|---|---|---|
| **1.0** | **Fursa Zone Registration** | Fixed payload key (`program` vs `programm`), auto-fill enabled | Accept both `program` and `programm` in DTO; check duplicate registration cleanly | **High** |
| **4.0** | **Converter (Image to PDF)** | Handles PDF view/download | Fix server converter: encapsulate JPG/JPEG into PDF page rather than extracting plain text/OCR | **Critical** |
| **1.0** | **Course Modules Blank** | Fallback to `GET /courses/:id/modules` implemented | Ensure `GET /courses/:id` eager-loads `modules` or `GET /courses/:id/modules` returns modules list | **High** |
| **3.0** | **Prep: AI Question Generation** | UI file picker ready for docs, ppt, pdf, xlsx | Provide `POST /prep/generate-questions` accepting files and returning structured AI questions | **High** |
| **3.0** | **Library Helpful & Read Counts** | Client-side reactive increment | Provide `POST /library/books/:id/like` and `POST /library/books/:id/read` | **Medium** |
| **3.0** | **Students Directory & Search** | Dropdown filters implemented in UI | Add filter query params to `GET /users` or `GET /friendships/students` (`universityId`, `program`, `yearOfStudy`, `search`) | **High** |
| **4.0** | **Campaign & Event Company Logo** | UI updated to display Company Logo & Name | Include `companyLogo` and `companyName` directly in `GET /campaigns/published` and `GET /events` | **Medium** |
| **3.0** | **Gigs Global Visibility** | Screen ready to list all | Remove creator/university restriction in `GET /gig/all` so gigs are visible across all universities | **High** |
| **3.0.3**| **Chat "Invalid receivers"** | Verified recipient ID parsing | Ensure `POST /chat` resolves existing 1-on-1 rooms without throwing "Invalid receivers" | **High** |
| **1.0** | **CV Creation Failure** | Form validated with Male/Female and +255 | Verify `CreateCvDto` accepts all nullable optional fields without 400 rejection | **High** |
| **2.0** | **Job & Scholarship Extra Documents** | 7-step & 10-step PDF upload flows implemented | Add columns/DTO fields for `certificates`, `identityProofUrl`, `photoUrl`, `recruiterEmail`, `recruiterUrl`, `academicTranscriptUrl`, etc. | **Critical** |
| **5.0.2**| **Feedback Alerts (Both Ends)** | Instant UI feedback & local alert | Send in-app/push notification to Admin on feedback, and push notification to Student on response | **Medium** |
| **5.0.1**| **Account Soft Delete & Sessions** | Single session UI supported | Implement soft delete checking active subscription time; enforce single active device session | **Medium** |

---

## 1. Fursa Zone Registration (`POST /registrations`)

### Issue
When students submit their registration for a competition, the server returns `Registration failed` or 400 Bad Request.

### Backend DTO & Controller Fix
In `create-registration.dto.ts`:
```typescript
import { IsNotEmpty, IsNumber, IsOptional, IsString } from 'class-validator';

export class CreateRegistrationDto {
  @IsNumber()
  @IsNotEmpty()
  competitionId: number;

  @IsString()
  @IsNotEmpty()
  fullName: string;

  @IsString()
  @IsNotEmpty()
  email: string;

  @IsString()
  @IsNotEmpty()
  studentId: string;

  @IsString()
  @IsNotEmpty()
  university: string;

  // FIX: Accept both 'program' and 'programm' to prevent validation failure
  @IsString()
  @IsOptional()
  program?: string;

  @IsString()
  @IsOptional()
  programm?: string;
}
```

In the service handler:
```typescript
const programName = dto.program || dto.programm || 'General';
// Check if user is already registered for this competition
const existing = await this.registrationRepo.findOne({
  where: { competitionId: dto.competitionId, userId: currentUser.id }
});
if (existing) {
  return { success: true, message: 'Already registered', data: existing };
}
```

---

## 2. File Converter Microservice (`POST /convert/:fileId`)

### Issue
Converting JPG/JPEG to PDF returns plain text / OCR text (`"Picture turn into txt"`).

### Backend Fix
When `targetFormat === 'pdf'` and input file MIME type is `image/jpeg` or `image/png`:
1. Do **NOT** run OCR or text extraction.
2. Embed the image into a standard PDF container using `pdfkit` or `sharp`:
```typescript
import PDFDocument from 'pdfkit';

export async function convertImageToPdf(imageBuffer: Buffer): Promise<Buffer> {
  return new Promise((resolve, reject) => {
    const doc = new PDFDocument({ autoFirstPage: false });
    const chunks: Buffer[] = [];

    doc.on('data', chunk => chunks.push(chunk));
    doc.on('end', () => resolve(Buffer.concat(chunks)));
    doc.on('error', reject);

    const img = doc.openImage(imageBuffer);
    doc.addPage({ size: [img.width, img.height] });
    doc.image(img, 0, 0);
    doc.end();
  });
}
```
Set header `Content-Type: application/pdf` and `Content-Disposition: attachment; filename="converted.pdf"`.

---

## 3. Course Modules Relation (`GET /courses/:id` & `GET /courses/:id/modules`)

### Issue
When students open a course, modules display blank because `GET /courses/:id` does not join `modules`.

### Backend Fix
In `courses.service.ts`:
```typescript
async getCourseById(courseId: number) {
  return await this.courseRepository.findOne({
    where: { id: courseId },
    relations: [
      'modules',
      'modules.classes',
      'modules.files',
      'instructor',
    ],
    order: {
      modules: { order: 'ASC' }
    }
  });
}
```
Ensure `GET /courses/:courseId/modules` also returns active modules for enrolled students.

---

## 4. Academics Prep AI Generation (`POST /prep/generate-questions`)

### Requirements
Students upload course modules (`.docx`, `.pptx`, `.pdf`, `.xlsx`), and AI generates practice questions based on the uploaded content.

### Proposed Endpoint
- **URL**: `POST /prep/generate-questions` (or on AI microservice `POST /create/prep-questions`)
- **Headers**: `Authorization: Bearer <token>`, `Content-Type: multipart/form-data`
- **Form Data**:
  - `file`: Document file (`.pdf`, `.docx`, `.pptx`, `.xlsx`)
  - `questionCount`: `number` (default: 10)
  - `difficulty`: `'easy' | 'medium' | 'hard'`
  - `topic`: `string` (optional override)
- **Response Format**:
```json
{
  "success": true,
  "data": {
    "topic": "Physics Fundamentals",
    "totalQuestions": 10,
    "questions": [
      {
        "id": "q1",
        "questionText": "What is the unit of electric current?",
        "options": ["Volt", "Ampere", "Ohm", "Watt"],
        "correctIndex": 1,
        "explanation": "Ampere is the base unit of electric current in the International System of Units."
      }
    ]
  }
}
```

---

## 5. Library Engagement Endpoints

Provide endpoints to increment and track user reads and likes on library books:
- `POST /library/books/:id/like` -> Toggles like / helpful, increments/decrements `totalLikes`.
- `POST /library/books/:id/read` -> Marks book as read for the user, increments `totalReads`.

---

## 6. Students Directory & Search Filter (`GET /users` or `GET /friendships/all-students`)

### Issue
In the Campus "Students" tab, students need to see a paginated list of all students across all universities, filtered by:
1. `universityId` or `universityName`
2. `program` (e.g. Bachelor Degree in Finance)
3. `yearOfStudy` (1st Year, 2nd Year, 3rd Year, 4th Year, 5th Year)
4. `search` (name, username, student ID)

### Backend Endpoint Specification
- **URL**: `GET /users?role=student&page=1&limit=20`
- **Query Params**:
  - `universityId`: `number` (optional)
  - `program`: `string` (optional)
  - `yearOfStudy`: `string` (optional)
  - `search`: `string` (optional)
- **Response Format**:
```json
{
  "data": [
    {
      "id": 101,
      "fullName": "Jane Doe",
      "username": "janedoe",
      "profilePic": "https://...",
      "university": { "id": 2, "name": "JUCO" },
      "program": "Bachelor Degree in Finance",
      "yearOfStudy": "4th Year",
      "friendshipStatus": "none" // "none" | "pending" | "accepted"
    }
  ],
  "meta": {
    "currentPage": 1,
    "totalPages": 5,
    "totalItems": 95
  }
}
```

---

## 7. Company Logo in Campaign & Event Responses

### Issue
Campaign details and Event details lack the company logo URL in the API response.

### Backend Fix
In the serializer/transformer for `GET /campaigns/published` and `GET /events`:
Ensure each item returns:
```json
{
  "id": 1,
  "campaignTitle": "Tech Innovators Challenge",
  "companyName": "CRDB Bank",
  "companyLogo": "https://.../logo.png",
  "author": {
    "id": 5,
    "proPartnerName": "CRDB Bank",
    "companyLogo": "https://.../logo.png"
  }
}
```

---

## 8. Gigs Global Visibility (`GET /gig/all`)

### Issue
Created gigs are only visible to the creator. They must be visible to students from all universities.

### Backend Fix
In `gigs.service.ts`:
Remove any filter scoping gigs by `currentUserId` or strict university restriction on the public feed:
```typescript
async getAllGigs(query: GetGigsQueryDto) {
  const qb = this.gigRepository.createQueryBuilder('gig')
    .leftJoinAndSelect('gig.author', 'author')
    .where('gig.status = :status', { status: 'published' });

  // Do NOT filter by req.user.id or req.user.universityId for public feed
  return await qb.orderBy('gig.createdAt', 'DESC').getMany();
}
```

---

## 9. Chat "Invalid receivers" Fix (`POST /chat`)

### Issue
Tapping "Contact Me" on a Gig or Student card errors with `"Invalid receivers"`.

### Backend Fix
In `chat.service.ts`:
1. Ensure receiver ID is parsed as integer.
2. If `currentUserId === receiverId`, return bad request (`"Cannot chat with yourself"`).
3. If a 1-on-1 chat room between `currentUserId` and `receiverId` already exists, return the existing room rather than throwing an exception:
```typescript
const existingRoom = await this.chatRoomRepository
  .createQueryBuilder('room')
  .innerJoin('room.participants', 'p1', 'p1.userId = :u1', { u1: currentUserId })
  .innerJoin('room.participants', 'p2', 'p2.userId = :u2', { u2: targetUserId })
  .where('room.isGroup = false')
  .getOne();

if (existingRoom) {
  return existingRoom;
}
```

---

## 10. Extended Job & Scholarship Application Schemas

### Issue
Students need to attach PDF documents: Cover/Motivation Letter, multiple Certificates, CV, Proof of Identity, Recommendation Letters, etc.

### Database Updates (TypeORM Entity)
In `job-application.entity.ts` and `scholarship-application.entity.ts`:
```typescript
@Column({ type: 'jsonb', default: () => "'[]'", nullable: true })
certificates?: string[]; // Array of Cloudinary/S3 PDF URLs

@Column({ type: 'varchar', length: 500, nullable: true })
identityProofUrl?: string; // Passport, National ID, Birth Certificate PDF

@Column({ type: 'varchar', length: 500, nullable: true })
photoUrl?: string; // Passport photo

@Column({ type: 'jsonb', default: () => "'[]'", nullable: true })
otherDocuments?: string[];

@Column({ type: 'varchar', length: 150, nullable: true })
recruiterEmail?: string;

@Column({ type: 'varchar', length: 500, nullable: true })
recruiterUrl?: string;

// Scholarship specific:
@Column({ type: 'varchar', length: 500, nullable: true })
academicTranscriptUrl?: string;

@Column({ type: 'jsonb', default: () => "'[]'", nullable: true })
recommendationLetterUrls?: string[];

@Column({ type: 'varchar', length: 500, nullable: true })
applicationFormUrl?: string;
```

---

## 11. Alerts & Push Notifications for Feedback (`POST /feedbacks`)

1. **Student sends feedback**:
   - Save record to `feedbacks` table.
   - Dispatch WebSocket event to Admin portal / create Admin notification:
     `"New student feedback received from ${user.fullName}"`.
2. **Admin responds to feedback**:
   - Save response in `feedback_responses`.
   - Dispatch FCM push notification to student device:
     - Title: `"Support Response"`
     - Body: `"An administrator has responded to your feedback."`
     - Data: `{"type": "FEEDBACK_RESPONSE", "feedbackId": id}`
