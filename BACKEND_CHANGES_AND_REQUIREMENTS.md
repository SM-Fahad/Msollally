# LinkYetu / Pro-Partner Backend Changes & Technical Requirements

This document outlines all backend fixes, schema updates, WebSocket events, and API requirements identified from the QA testing feedback document (8 pages).

---

## Executive Summary & Status Matrix

| # | Feedback Area | Mobile (Flutter) Status | Backend Action Required | Priority |
|---|---|---|---|---|
| **1.0** | **Pro-Partner & Student Chat** | ✅ Handled socket listening, REST fallback & deep navigation | Ensure WebSocket broadcasts to both rooms + FCM Push Notification trigger | **High** |
| **1.0** | **Dashboard Unread Message Count** | ✅ Calculated dynamically from active chat rooms | Add `unreadMessagesCount` to `GET /pro-partner/me` or provide `GET /chat/unread-count` | **Medium** |
| **1.0.2** | **Campaign & Event Audience Targeting** | ✅ Client-side fallback filtering by student profile implemented | Implement database-level targeting filters on `GET /campaigns` and `GET /events` | **Critical** |
| **1.0.2** | **Feed Pagination / Limit Issue (Seeing only 6/9)** | ✅ Client requested 50 items with scroll listener | Update default pagination limit and handle `?page=1&limit=20` query parameters | **High** |
| **1.0.3** | **Campaign Total Budget** | ✅ Made optional in UI & validation | Make `totalBudget` nullable / optional in DTO & database column | **Medium** |
| **3.0.2** | **Job Creation Crash (`otherExperienceLevel`)** | ✅ Omitted from raw payload to prevent 500 crash | Add `otherExperienceLevel` column to `Job` entity, or remove constraint | **High** |
| **3.0.3** | **Job Experience Requirements** | ✅ Minimum & Maximum made optional | Make `minimumExperience` and `maximumExperience` optional in DTOs | **Medium** |
| **3.0.4** | **Job Department & Location Optional** | ✅ Made optional in UI & validation | Make `department` and `location` optional / nullable in `Job` entity & DTOs | **Medium** |
| **3.0.4** | **Job Reporting Line Field** | ✅ Added field in UI (saved in description fallback) | Add `reportingLine` column to `Job` entity and DTOs | **Medium** |
| **1.0.4.2**| **Edit Profile Field Restrictions** | ✅ Restricted UI editing to only Email and Bio | Add server-side validation whitelist preventing mutation of name, cell, company | **High** |
| **1.0.4.2**| **Change Password Email & Alert** | ✅ Triggered local security notification on device | Send security notification email via backend mailer service upon password update | **High** |
| **1.0.4.4**| **Device Sessions (Single Device Control)** | ✅ Screen & IP tracking supported | Enforce single-device session or OTP verification on new device login | **High** |
| **1.0.4.4**| **Pro-Partner Registration vs Subscription** | ✅ Removed $25/month subscription card; replaced with Registration Status | Return `registrationStatus: 'approved' \| 'pending'` in user profile | **Medium** |
| **2.0** | **Help & Support / Instructional Videos** | ✅ Added LinkYetu contacts & tutorial video player tabs | Provide `GET /help-support/tutorials` endpoint to manage videos dynamically | **Low** |

---

## Detailed Requirements for Backend Developers

### 1. Job Entity & TypeORM Fixes (Resolves 500 Crash)

#### A. Issue:
When a Pro-Partner created or updated a job with `experienceLevel: "other"`, the backend crashed with:
```
Property "otherExperienceLevel" was not found in "Job". Make sure your query is correct.
```

#### B. Required Database & Entity Changes:
In your NestJS / TypeORM `Job` entity file (`job.entity.ts`):
```typescript
@Entity('jobs')
export class Job {
  // Existing columns...
  
  @Column({ type: 'varchar', length: 150, nullable: true })
  reportingLine?: string; // NEW: Added as per QA feedback

  @Column({ type: 'varchar', length: 255, nullable: true })
  otherExperienceLevel?: string; // FIX: Missing column causing 500 crash

  @Column({ type: 'int', default: 0, nullable: true })
  minimumExperience?: number; // Must be nullable or default to 0

  @Column({ type: 'int', default: 0, nullable: true })
  maximumExperience?: number; // Must be nullable or default to 0

  @Column({ type: 'varchar', length: 150, nullable: true })
  department?: string; // Optional as per feedback

  @Column({ type: 'varchar', length: 200, nullable: true })
  location?: string; // Optional as per feedback

  @Column({ type: 'jsonb', default: () => "'[]'", nullable: true })
  otherFacilities?: string[]; // Optional as per feedback
}
```

#### C. DTO Validation Updates:
In `create-job.dto.ts` and `update-job.dto.ts`:
```typescript
export class CreateJobDto {
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsString()
  @IsNotEmpty()
  companyName: string;

  @IsString()
  @IsOptional()
  department?: string; // Optional

  @IsString()
  @IsOptional()
  reportingLine?: string; // Optional

  @IsString()
  @IsOptional()
  location?: string; // Optional

  @IsString()
  @IsNotEmpty()
  jobType: string;

  @IsString()
  @IsOptional()
  salaryType?: string;

  @IsNumber()
  @IsOptional()
  minimumSalary?: number;

  @IsNumber()
  @IsOptional()
  maximumSalary?: number;

  @IsString()
  @IsNotEmpty()
  description: string;

  @IsArray()
  @IsOptional()
  responsibilities?: string[];

  @IsArray()
  @IsOptional()
  requirements?: string[];

  @IsArray()
  @IsOptional()
  benefits?: string[];

  @IsArray()
  @IsOptional()
  professionalSkills?: string[];

  @IsArray()
  @IsOptional()
  otherFacilities?: string[]; // Optional

  @IsString()
  @IsNotEmpty()
  experienceLevel: string;

  @IsString()
  @IsOptional()
  otherExperienceLevel?: string; // Add to DTO

  @IsNumber()
  @IsOptional()
  minimumExperience?: number; // Optional

  @IsNumber()
  @IsOptional()
  maximumExperience?: number; // Optional

  @IsDateString()
  @IsNotEmpty()
  applicationDeadline: string;

  @IsString()
  @IsOptional()
  companyLogo?: string;
}
```

---

### 2. Campaign & Event Audience Feed Targeting (Database-Level)

#### A. Issue:
Students of unrelated majors (e.g. Business students) were receiving campaigns and events specifically targeted at Computer Science students. Furthermore, students were only seeing 6 campaigns or 9 events due to hardcoded backend pagination limits.

#### B. Required Query Logic:
When returning the student feed (`GET /campaigns` or `GET /student/campus/campaigns`), filter based on the authenticated student's profile:

```typescript
async getStudentCampaignFeed(studentUser: User, page = 1, limit = 20) {
  const query = this.campaignRepository.createQueryBuilder('campaign')
    .where('campaign.status = :status', { status: 'published' })
    .andWhere('(campaign.startDate IS NULL OR campaign.startDate <= NOW())')
    .andWhere('(campaign.endDate IS NULL OR campaign.endDate >= NOW())');

  // 1. University Targeting Filter
  if (studentUser.universityId) {
    query.andWhere(
      `(campaign.targetUniversities IS NULL 
        OR 'all' = ANY(campaign.targetUniversities) 
        OR :universityId = ANY(campaign.targetUniversities))`,
      { universityId: studentUser.universityId }
    );
  }

  // 2. Gender Targeting Filter
  if (studentUser.gender) {
    query.andWhere(
      `(campaign.targetGender IS NULL 
        OR campaign.targetGender = 'any' 
        OR LOWER(campaign.targetGender) = LOWER(:gender))`,
      { gender: studentUser.gender }
    );
  }

  // 3. Major / Department Targeting Filter
  if (studentUser.major) {
    query.andWhere(
      `(campaign.targetMajors IS NULL 
        OR 'all' = ANY(campaign.targetMajors) 
        OR LOWER(:major) = ANY(ARRAY(SELECT LOWER(x) FROM UNNEST(campaign.targetMajors) t(x))))`,
      { major: studentUser.major }
    );
  }

  // 4. Year of Study Filter
  if (studentUser.yearOfStudy) {
    query.andWhere(
      `(campaign.targetYears IS NULL 
        OR 0 = ANY(campaign.targetYears) 
        OR :yearOfStudy = ANY(campaign.targetYears))`,
      { yearOfStudy: studentUser.yearOfStudy }
    );
  }

  return query
    .orderBy('campaign.createdAt', 'DESC')
    .skip((page - 1) * limit)
    .take(limit)
    .getManyAndCount();
}
```

#### C. Feed Pagination:
- Accept `?page=1&limit=20` query parameters.
- Default limit should be at least `20` (instead of 6 or 9).
- Return standard pagination metadata:
  ```json
  {
    "data": [...],
    "meta": {
      "total": 45,
      "page": 1,
      "limit": 20,
      "totalPages": 3,
      "hasNextPage": true
    }
  }
  ```

---

### 3. Chat WebSockets & Push Notifications (Pro-Partner ⇄ Student)

#### A. Issue:
When a Pro-Partner replied to a student's inquiry, the message was not received by the student in real-time, and no push notification was triggered.

#### B. Required WebSocket Event Logic:
In your WebSocket gateway (e.g., `ChatGateway`):
```typescript
@SubscribeMessage('sendMessage')
async handleSendMessage(
  @ConnectedSocket() client: Socket,
  @MessageBody() payload: { chatId: string; message: string; receiverId: string }
) {
  const savedMessage = await this.chatService.saveMessage(payload);

  // 1. Emit to chat room (if both users have room open)
  this.server.to(`chat_${payload.chatId}`).emit('messageReceived', savedMessage);

  // 2. Emit to receiver's dedicated user room (for inbox unread badge updates)
  this.server.to(`user_${payload.receiverId}`).emit('newNotification', {
    type: 'chat',
    chatId: payload.chatId,
    message: savedMessage,
  });

  // 3. FCM Push Notification (if receiver is backgrounded/offline)
  const isOnline = await this.presenceService.isUserOnline(payload.receiverId);
  if (!isOnline) {
    await this.fcmService.sendNotification({
      userId: payload.receiverId,
      title: savedMessage.senderName || 'New Message',
      body: savedMessage.text,
      data: {
        entityType: 'chat',
        chatId: payload.chatId,
        senderId: savedMessage.senderId,
      },
    });
  }

  return savedMessage;
}
```

---

### 4. Security & Device Session Control

#### A. Password Change Email:
In `auth.service.ts` under `changePassword`:
```typescript
async changePassword(userId: string, changePasswordDto: ChangePasswordDto) {
  // Update password hash...

  // Send security email
  await this.mailerService.sendMail({
    to: user.email,
    subject: 'Security Alert: Password Changed',
    template: 'password-changed',
    context: {
      userName: user.firstName,
      date: new Date().toUTCString(),
      deviceInfo: request.headers['user-agent'],
    },
  });

  // Log audit session
  await this.auditLogService.log(userId, 'PASSWORD_CHANGE');
}
```

#### B. Single-Device Session Control (PDF Page 7, 1.0.4.4):
- When a user logs in (`POST /auth/login`):
  - Store the active `deviceId` or active `refreshToken` hash in Redis / User record.
  - If a login attempt occurs on an unrecognized device:
    - Option 1 (Strict Single Device): Invalidate all prior refresh tokens so previous devices are logged out upon token expiry.
    - Option 2 (OTP Verification): If device is unrecognized, trigger an SMS OTP to the registered phone number before issuing JWT tokens.

---

### 5. Pro-Partner Registration vs Subscription Model

#### A. Issue:
The app previously had UI placeholders for a `$25/Month` paid subscription with `Cancel Subscription`. As specified by QA, Pro-Partners do **not** have paid subscriptions. They register via the app and are approved from the Admin Portal.

#### B. Backend Profile Status:
Ensure `GET /pro-partner/me` (or `GET /users/me`) returns:
```json
{
  "id": "123",
  "email": "partner@company.com",
  "registrationStatus": "approved", // "pending" | "approved" | "rejected"
  "isVerified": true,
  "approvedAt": "2026-08-25T10:00:00Z",
  "planType": "free_partner"
}
```
Remove any Stripe/recurring payment mandates for the Pro-Partner role.

---

### 6. Profile Editing Field Protection

#### A. Requirement:
Pro-Partners should only be allowed to update their **Email** and **Bio**.
Fields like **Name**, **Cell**, **Company Name**, **Designation**, and **Industry Type** require admin review to prevent fraud.

#### B. Backend Controller Protection:
In `pro-partner.controller.ts`:
```typescript
@Patch('profile')
async updateProfile(
  @CurrentUser() user: User,
  @Body() dto: UpdateProPartnerProfileDto
) {
  // Whitelist only email and bio for partner self-service:
  const allowedUpdates = {
    email: dto.email,
    bio: dto.bio,
    coverPhoto: dto.coverPhoto,
    avatar: dto.avatar,
  };

  return this.proPartnerService.updateProfile(user.id, allowedUpdates);
}
```

---

## Verification Checklist for Backend Deployment

- [ ] Run database migration adding `otherExperienceLevel` and `reportingLine` columns to the `jobs` table.
- [ ] Verify `POST /jobs` does not fail when `otherExperienceLevel` is submitted.
- [ ] Verify `GET /campaigns` filters results by university, major, gender, and year.
- [ ] Confirm `sendMessage` socket event triggers both room broadcast and FCM push notification to students.
- [ ] Verify `POST /auth/change-password` triggers an automated security confirmation email.
- [ ] Verify `GET /pro-partner/me` returns `registrationStatus` instead of paid subscription tier.
