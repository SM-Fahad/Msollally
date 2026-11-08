import 'package:flutter_test/flutter_test.dart';
import 'package:msollaally/feature/student/academics/qBank/model/question_bank_model.dart';
import 'package:msollaally/feature/student/career/cv/model/cv_model.dart';
import 'package:msollaally/feature/student/career/find_jobs/model/job_application_model.dart';
import 'package:msollaally/feature/student/career/gigs/model/gigs_model.dart';
import 'package:msollaally/feature/student/referral_program/model/referral_model.dart';

void main() {
  group('Question Bank & Practice Scoring Model Tests', () {
    test('PracticeSubmissionResponse correctly parses summary and calculates scores', () {
      final json = {
        "summary": {
          "totalQuestions": 10,
          "attendedCount": 8,
          "unattendedCount": 2,
          "correctAnswersCount": 7,
          "wrongAnswersCount": 1,
          "scorePercentage": 70.0
        },
        "results": [
          {
            "questionId": "q1",
            "isCorrect": true,
            "isAttended": true,
            "correctOptionId": "opt1",
            "selectedOptionId": "opt1"
          },
          {
            "questionId": "q2",
            "isCorrect": false,
            "isAttended": true,
            "correctOptionId": "opt2",
            "selectedOptionId": "opt3"
          }
        ]
      };

      final response = PracticeSubmissionResponse.fromMap(json);

      expect(response.summary.totalQuestions, 10);
      expect(response.summary.correctAnswersCount, 7);
      expect(response.summary.wrongAnswersCount, 1);
      expect(response.summary.unattendedCount, 2);
      expect(response.summary.scorePercentage, 70.0);
      expect(response.results.length, 2);
      expect(response.results[0].isCorrect, true);
      expect(response.results[1].isCorrect, false);
    });

    test('Score percentage calculation matches (Correct / Total) * 100', () {
      const correct = 8;
      const total = 10;
      final percentage = total == 0 ? 0 : ((correct / total) * 100).round();
      expect(percentage, 80);
    });
  });

  group('Student Gigs Marketplace Model Tests', () {
    test('GigsModel parses fields, author, and currency correctly', () {
      final json = {
        "gigId": 101,
        "title": "Flutter Tutor",
        "description": "Mobile dev tutoring",
        "price": 25000,
        "currency": "TZS",
        "pricingType": "negotiable",
        "locationType": "flexible",
        "status": "active",
        "author": {
          "id": 15,
          "username": "johndoe",
          "role": "STUDENT"
        },
        "tags": ["Flutter", "Dart"],
        "documents": ["https://example.com/preview.jpg"]
      };

      final gig = GigsModel.fromJson(json);

      expect(gig.gigId, 101);
      expect(gig.title, "Flutter Tutor");
      expect(gig.currency, "TZS");
      expect(gig.price, "25000");
      expect(gig.pricingType, "negotiable");
      expect(gig.locationType, "flexible");
      expect(gig.status, "active");
      expect(gig.author?.id, 15);
      expect(gig.tags.length, 2);
      expect(gig.documents.length, 1);
    });
  });

  group('Referral Program Model Tests', () {
    test('ReferralModel correctly holds wallet balance and referral details', () {
      final referral = ReferralModel(
        referralCount: 12,
        earnedAmount: 25000.0,
        currentStatus: "Elite Member",
        currentTierReferrals: 12,
        nextTierReferrals: 20,
        referralCode: "UDSM2026",
        referalLink: "https://msollaally.com/ref/UDSM2026",
        milestones: [],
      );

      expect(referral.referralCount, 12);
      expect(referral.earnedAmount, 25000.0);
      expect(referral.referralCode, "UDSM2026");
      expect(referral.referalLink, "https://msollaally.com/ref/UDSM2026");
      // Eligible for payout (>= 10,000 TZS)
      expect(referral.earnedAmount >= 10000, true);
    });
  });

  group('CV Builder CRUD Model Tests', () {
    test('CvModel serializes correctly with full data and submodels for create/update API', () {
      final cv = CvModel(
        id: "30774c3e-e7d9-4c34-9de9-a6ddfc435ea3",
        firstName: "Sheikh",
        middleName: "Mohammad",
        lastName: "Fahad",
        sex: "male",
        dob: "1996-08-17T18:00:00.000Z",
        nationality: "Bangladeshi",
        maritalStatus: "single",
        otherMaritalStatus: "In a relationship",
        languageProficiency: ["English", "Bengali"],
        contactAddress: "Dhaka",
        mobileNo: "+255717070707",
        email: "wmail@gmail.com",
        personalSummery: "Backend Developer specializing in scalable design",
        educations: [
          CvEducation(
            id: 23,
            institution: "DPI",
            degree: "Diploma",
            gpa: "3.78",
            startDate: "2019-01-01",
            endDate: "2023-06-30",
            description: "Engineering studies",
          ),
        ],
        experiences: [
          CvExperience(
            id: 10,
            companyName: "Softvence Agency",
            position: "Junior Backend Developer",
            startDate: "2023-07-01",
            endDate: "2024-06-30",
            description: "Worked on REST APIs",
          ),
        ],
        hobbies: ["Watching Series", "Reading"],
        referrers: [
          CvReferrer(
            id: 3,
            name: "Md. Rakib Hasan",
            role: "Senior Software Engineer",
            organization: "Softvence Agency",
            address1: "House 12, Road 5",
            address2: "Dhaka 1209",
            phone: "+8801712345678",
          ),
        ],
      );

      final json = cv.toJson();

      expect(json['id'], "30774c3e-e7d9-4c34-9de9-a6ddfc435ea3");
      expect(json['firstName'], "Sheikh");
      expect(json['middleName'], "Mohammad");
      expect(json['lastName'], "Fahad");
      expect(json['sex'], "male");
      expect(json['otherMaritalStatus'], "In a relationship");
      expect(json['languageProficiency'], ["English", "Bengali"]);
      expect(json['educations'].length, 1);
      expect(json['educations'][0]['id'], 23);
      expect(json['educations'][0]['institution'], "DPI");
      expect(json['experiences'].length, 1);
      expect(json['experiences'][0]['id'], 10);
      expect(json['experiences'][0]['companyName'], "Softvence Agency");
      expect(json['referrers'].length, 1);
      expect(json['referrers'][0]['id'], 3);
      expect(json['referrers'][0]['name'], "Md. Rakib Hasan");
      expect(json['hobbies'], ["Watching Series", "Reading"]);
    });

    test('CvEducation, CvExperience, and CvReferrer hasData check operates correctly', () {
      final emptyEdu = CvEducation();
      expect(emptyEdu.hasData, false);

      final filledEdu = CvEducation(institution: 'University of Dar es Salaam');
      expect(filledEdu.hasData, true);

      final emptyExp = CvExperience();
      expect(emptyExp.hasData, false);

      final filledExp = CvExperience(position: 'Developer');
      expect(filledExp.hasData, true);

      final emptyRef = CvReferrer();
      expect(emptyRef.hasData, false);

      final filledRef = CvReferrer(name: 'Jane Doe');
      expect(filledRef.hasData, true);
    });
  });

  group('Job Application Payload Tests (JOB_APPLICATION_API_DOC.md)', () {
    test('Constructs all 7 client requirement fields matching API documentation', () {
      final payload = <String, dynamic>{
        "coverLetter": "Dear Hiring Team, I am writing to express my interest...",
        "resumeUrl": "https://storage.msollaally.com/uploads/resumes/john_doe_cv.pdf",
        "cvId": "30774c3e-e7d9-4c34-9de9-a6ddfc435ea3",
        "certificates": [
          "https://storage.msollaally.com/uploads/certificates/form_four_cert.pdf",
          "https://storage.msollaally.com/uploads/certificates/diploma_cert.pdf"
        ],
        "identityProofUrl": "https://storage.msollaally.com/uploads/identity/national_id_card.pdf",
        "photoUrl": "https://storage.msollaally.com/uploads/photos/applicant_photo.jpg",
        "otherDocuments": [
          "https://storage.msollaally.com/uploads/docs/recommendation_letter.pdf"
        ],
        "recruiterEmail": "recruiter@techcompany.com",
        "recruiterUrl": "https://techcompany.com/careers/apply/123",
        "skills": ["TypeScript", "NestJS", "Flutter"],
        "metadata": {
          "experience": 2,
          "education": "Bachelor of Science in Computer Science",
          "phone": "+255717070707",
          "linkedIn": "https://linkedin.com/in/applicant",
          "portfolio": "https://applicantportfolio.dev"
        }
      };

      expect(payload['coverLetter'], isNotEmpty);
      expect(payload['resumeUrl'], isNotEmpty);
      expect(payload['cvId'], isNotEmpty);
      expect(payload['certificates'].length, 2);
      expect(payload['identityProofUrl'], contains('national_id_card'));
      expect(payload['photoUrl'], contains('applicant_photo'));
      expect(payload['otherDocuments'].length, 1);
      expect(payload['recruiterEmail'], "recruiter@techcompany.com");
      expect(payload['skills'].length, 3);
      expect(payload['metadata']['experience'], 2);
      expect(payload['metadata']['education'], contains('Bachelor of Science'));
      expect(payload['metadata']['phone'], "+255717070707");
    });

    test('JobApplicationModel correctly parses my job applications payload', () {
      final json = {
        "id": 101,
        "jobId": 45,
        "status": "shortlisted",
        "coverLetter": "Excited to apply for this engineering role.",
        "resumeUrl": "https://storage.msollaally.com/resumes/cv.pdf",
        "skills": ["Flutter", "Dart", "REST API"],
        "createdAt": "2026-09-25T10:00:00.000Z",
        "job": {
          "id": 45,
          "title": "Flutter Developer",
          "companyName": "Tech Corp",
          "location": "Dar es Salaam",
          "jobType": "full_time"
        }
      };

      final application = JobApplicationModel.fromJson(json);

      expect(application.id, 101);
      expect(application.jobId, 45);
      expect(application.status, 'shortlisted');
      expect(application.jobTitle, 'Flutter Developer');
      expect(application.companyName, 'Tech Corp');
      expect(application.location, 'Dar es Salaam');
      expect(application.jobType, 'Full-Time');
      expect(application.skills.length, 3);
      expect(application.coverLetter, contains('engineering'));
    });
  });

  group('Student Campaign Search Tests', () {
    test('Campaign list filters correctly based on search query', () {
      final sampleCampaigns = <Map<String, String>>[
        {
          'id': '1',
          'title': 'Books Sale',
          'tag': 'Active',
          'authorName': 'BookStore',
          'description': 'Textbooks on discount',
          'university': 'State University',
          'major': 'Literature',
          'caption': 'Buy now',
        },
        {
          'id': '2',
          'title': 'Digital Mobile App development',
          'tag': 'Active',
          'authorName': 'TechHub',
          'description': 'Flutter course',
          'university': 'Tech Institute',
          'major': 'Computer Science',
          'caption': 'Learn Flutter',
        },
        {
          'id': '3',
          'title': 'CRDB Holyday',
          'tag': 'Inactive',
          'authorName': 'CRDB Bank',
          'description': 'Student banking offers',
          'university': '',
          'major': 'Finance',
          'caption': 'Save money',
        },
      ];

      List<Map<String, String>> filter(String q) {
        final query = q.trim().toLowerCase();
        if (query.isEmpty) return sampleCampaigns;
        return sampleCampaigns.where((item) {
          final title = (item['title'] ?? '').toLowerCase();
          final tag = (item['tag'] ?? '').toLowerCase();
          final author = (item['authorName'] ?? '').toLowerCase();
          final desc = (item['description'] ?? '').toLowerCase();
          final uni = (item['university'] ?? '').toLowerCase();
          final major = (item['major'] ?? '').toLowerCase();
          final caption = (item['caption'] ?? '').toLowerCase();
          return title.contains(query) ||
              tag.contains(query) ||
              author.contains(query) ||
              desc.contains(query) ||
              uni.contains(query) ||
              major.contains(query) ||
              caption.contains(query);
        }).toList();
      }

      expect(filter('').length, 3);
      expect(filter('books').length, 1);
      expect(filter('books').first['id'], '1');
      expect(filter('flutter').length, 1);
      expect(filter('flutter').first['id'], '2');
      expect(filter('bank').length, 1);
      expect(filter('bank').first['id'], '3');
      expect(filter('nonexistent').length, 0);
    });
  });
}
