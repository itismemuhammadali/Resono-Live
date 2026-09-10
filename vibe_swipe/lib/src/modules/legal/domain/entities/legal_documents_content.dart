class LegalDocumentSection {
  final String id;
  final String title;
  final String iconName;
  final String summary;
  final String listenerContent;
  final String artistContent;

  const LegalDocumentSection({
    required this.id,
    required this.title,
    required this.iconName,
    required this.summary,
    required this.listenerContent,
    required this.artistContent,
  });
}

class LegalDocumentsContent {
  static const List<LegalDocumentSection> sections = [
    LegalDocumentSection(
      id: 'terms',
      title: 'Terms & Conditions',
      iconName: 'gavel',
      summary: 'Users 13+, neutral intermediary status, spam prohibition, anti-harassment, and off-platform engagement rules.',
      listenerContent: '''
# 1. Terms of Use & EULA Agreement

**Last Updated: September 10, 2026**
**Entity: VibeSwipe LLC**

Users must be 13+ to sign up on the platform as a listener or an artist under US law. VibeSwipe operates purely as a neutral intermediary.

---

### 0. End User License Agreement (EULA) & Zero-Tolerance Policy
• **Zero-Tolerance Policy:** VibeSwipe maintains a strict zero-tolerance policy for objectionable content and abusive users.
• **Prohibited Content:** Users are strictly forbidden from posting, transmitting, or sharing objectionable content, including but not limited to hate speech, harassment, bullying, sexually explicit content, defamation, violence, or spam.
• **Immediate Action & Termination:** Any user found posting objectionable content or engaging in abusive behavior will have their content removed immediately and their account suspended or permanently banned.
• **Flagging & Blocking Tools:** Users are provided built-in mechanisms to report objectionable content and permanently block abusive users. Blocking immediately removes that user's content from your feed and alerts our moderation team.

---

### 1. Age Eligibility & Verification
• **Age Limit:** Users must be at least 13 years of age to register or use VibeSwipe as a listener or artist under US law.
• **Neutral Intermediary:** VibeSwipe operates purely as a neutral intermediary connecting artists and listeners.

### 2. User Conduct & Community Guidelines
• **Spam & Fake Engagement:** Any form of spam, bot activity, or fake engagement (fake likes, stream inflations) is strictly against company policy.
• **Prohibited Conduct:** Harassment, abuse, hate speech, and off-platform engagement or off-platform payment circumvention are strictly prohibited.
• **Enforcement:** Accounts violating these terms face immediate suspension or permanent termination.
''',
      artistContent: '''
# 1. Terms of Use & EULA Agreement (Artist & Performer)

**Last Updated: September 10, 2026**
**Entity: VibeSwipe LLC**

Users must be 13+ to sign up on the platform as a listener or an artist under US law. VibeSwipe operates purely as a neutral intermediary.

---

### 0. End User License Agreement (EULA) & Zero-Tolerance Policy
• **Zero-Tolerance Policy:** VibeSwipe maintains a strict zero-tolerance policy for objectionable content and abusive users.
• **Prohibited Content & Streams:** Artists are strictly forbidden from uploading or broadcasting objectionable content, including hate speech, pornography/nudity, violence, copyright-infringing audio, or harassment.
• **Immediate Action & Termination:** Any artist found distributing objectionable content will have their content removed immediately, live stream terminated, and account permanently banned.
• **Moderation & Reporting:** All performances, community posts, and comments are subject to real-time moderation, user flagging, and developer review.

---

### 1. Artist Eligibility & Neutral Intermediary Status
• **Age Limit:** Artists must be 13+ under US law to create an account and participate on the platform.
• **Platform Role:** VibeSwipe operates purely as a neutral intermediary host for artist streams, media, and creator-fan interactions.

### 2. Creator Conduct & Strict Policies
• **Spam & Artificial Streams:** Generating fake views, automated tips, or artificial streams violates platform terms.
• **Anti-Harassment & Directing Off-Platform:** Off-platform engagement to bypass platform fees, as well as any form of harassment, is strictly banned.
''',
    ),

    LegalDocumentSection(
      id: 'privacy',
      title: 'Privacy Policy',
      iconName: 'shield',
      summary: 'Data collection (account, location, bank, telemetry), internal legal restriction, and payment partner data sharing.',
      listenerContent: '''
# 2. Privacy Policy

**Last Updated: August 13, 2026**
**Entity: VibeSwipe LLC**

We collect account information, User location, bank details, audio and device telemetry for official use only. Your information is only limited to the legal department of the company and shall never be used for any purpose other than the basic functions of VibeSwipe. Data is regularly shared with payment platforms such as Stripe and other similar platforms.

---

### 1. Data Collection Categories
• **Account & Profile:** Name, email, authentication tokens, profile details.
• **Location & Telemetry:** User location, audio metrics, and device telemetry collected exclusively for official system functions.
• **Financial Data:** Bank details and transaction logs processed for platform operations.

### 2. Access Limits & Data Sharing
• **Internal Confidentiality:** Access to personal information is strictly restricted to the legal and official departments of the company.
• **Third-Party Payment Platforms:** Data is regularly shared with payment processing platforms such as Stripe and similar authorized partners to complete payment functions.
''',
      artistContent: '''
# 2. Privacy Policy (Artist & Creator Data)

**Last Updated: August 13, 2026**
**Entity: VibeSwipe LLC**

We collect account information, User location, bank details, audio and device telemetry for official use only. Your information is only limited to the legal department of the company and shall never be used for any purpose other than the basic functions of VibeSwipe. Data is regularly shared with payment platforms such as Stripe and other similar platforms.

---

### 1. Information Collected for Creators
• **Creator Information:** Account credentials, precise location, bank details, audio streams, and device telemetry.
• **Scope of Use:** Data is collected solely for official platform operation, payout verification, and performance analysis.

### 2. Legal Department Oversight & Payout Partners
• **Internal Privacy Controls:** Information is restricted exclusively to the legal department of VibeSwipe.
• **Payment Gateways:** Financial and identity data is regularly shared with Stripe and verified payment partners to process payouts and tax compliance.
''',
    ),

    LegalDocumentSection(
      id: 'content',
      title: 'Terms of Service & Content Licensing',
      iconName: 'music_note',
      summary: 'Non-exclusive global streaming license, stream moderation, US federal subscription & ad regulations.',
      listenerContent: '''
# 3. Terms of Service & Content Licensing

**Last Updated: August 13, 2026**
**Entity: VibeSwipe LLC**

Artists shall grant VibeSwipe a non-exclusive, global license to stream and market their uploaded content. Streams shall be moderated. Subscriptions and ad placements shall be regulated under Federal US laws.

---

### 1. Content Rights & Streaming Access
• **Streaming Access:** Streams and broadcasts on VibeSwipe are provided under license from participating artists.
• **Stream Moderation:** All audio and live streams are actively moderated to ensure compliance with community standards and US laws.

### 2. Subscriptions & Advertisements
• **Federal Compliance:** Platform subscriptions and advertisement placements are strictly regulated under US Federal laws.
''',
      artistContent: '''
# 3. Terms of Service & Content Licensing (Artist License)

**Last Updated: August 13, 2026**
**Entity: VibeSwipe LLC**

Artists shall grant VibeSwipe a non-exclusive, global license to stream and market their uploaded content. Streams shall be moderated. Subscriptions and ad placements shall be regulated under Federal US laws.

---

### 1. Content License Grant
• **Global License:** By uploading or broadcasting on VibeSwipe, artists grant VibeSwipe a non-exclusive, worldwide license to stream, host, and market their uploaded content.
• **Ownership:** Artists retain underlying copyright ownership while licensing streaming rights to VibeSwipe.

### 2. Moderation & Ad/Subscription Regulation
• **Active Moderation:** Live streams and uploaded media are subject to continuous content moderation.
• **US Federal Laws:** Monetization options, including listener subscriptions and ad placements, strictly comply with US Federal regulations.
''',
    ),

    LegalDocumentSection(
      id: 'copyright',
      title: 'Copyright & Music Content Policy',
      iconName: 'copyright',
      summary: 'DMCA provisions, 100% ownership warranty, prompt removal of infringing content, safe harbor compliance.',
      listenerContent: '''
# 4. Copyright & Music Content Policy

**Last Updated: August 13, 2026**
**Entity: VibeSwipe LLC**

As per the provisions of DMCA (Digital Millenium Copyright Act), Artists shall warrant 100% copyright ownership and valid licenses. VibeSwipe has the right to promptly remove infringing content and shall terminate infringing users who fail to comply with the terms and conditions under US safe harbor law.

---

### 1. DMCA & Safe Harbor Compliance
• **DMCA Protection:** VibeSwipe adheres strictly to Digital Millennium Copyright Act (DMCA) provisions and US safe harbor laws.
• **Takedown Enforcement:** VibeSwipe maintains the right to promptly remove infringing audio or visual content upon notification.

### 2. Repeat Infringer Termination
• Users or artists failing to comply with copyright terms will face account termination under safe harbor guidelines.
''',
      artistContent: '''
# 4. Copyright & Music Content Policy (DMCA & Artist Warranties)

**Last Updated: August 13, 2026**
**Entity: VibeSwipe LLC**

As per the provisions of DMCA (Digital Millenium Copyright Act), Artists shall warrant 100% copyright ownership and valid licenses. VibeSwipe has the right to promptly remove infringing content and shall terminate infringing users who fail to comply with the terms and conditions under US safe harbor law.

---

### 1. Artist Copyright Warranty
• **100% Ownership Warranty:** Artists must warrant 100% copyright ownership or hold valid, documentation-backed licenses for all uploaded audio, tracks, and broadcasts.
• **Strict DMCA Compliance:** VibeSwipe strictly operates under the Digital Millennium Copyright Act (DMCA).

### 2. Infringement Actions & Termination
• **Prompt Content Removal:** VibeSwipe reserves the absolute right to promptly remove any alleged or verified infringing content.
• **Account Termination:** Repeat infringers and non-compliant users will be terminated pursuant to US safe harbor requirements.
''',
    ),

    LegalDocumentSection(
      id: 'payments',
      title: 'Payment & Subscription (Payout Policy)',
      iconName: 'payments',
      summary: 'Platform fee deduction, US IRS tax forms, Stripe Connect KYC verification, chargeback & FTC ad compliance.',
      listenerContent: '''
# 5. Payment & Subscription (Payout Policy)

**Last Updated: August 13, 2026**
**Entity: VibeSwipe LLC**

VibeSwipe reserves the right to deduct platform fee on all monetization. All artists must submit complete US IRS tax forms and Stripe Connect KYC Verification. Account Holders are responsible for chargebacks and FTC(Federal Trade Commission) ad compliance.

---

### 1. Platform Monetization & Fees
• **Monetization Charges:** VibeSwipe deducts platform fees on all monetization transactions (tickets, tips, subscriptions).
• **Chargeback Liability:** Account holders are fully responsible for payment chargebacks and FTC ad compliance.
''',
      artistContent: '''
# 5. Payment & Subscription (Payout Policy - Creator Earnings)

**Last Updated: August 13, 2026**
**Entity: VibeSwipe LLC**

VibeSwipe reserves the right to deduct platform fee on all monetization. All artists must submit complete US IRS tax forms and Stripe Connect KYC Verification. Account Holders are responsible for chargebacks and FTC(Federal Trade Commission) ad compliance.

---

### 1. Monetization & Fee Deductions
• **Platform Fee:** VibeSwipe reserves the right to deduct platform operational fees on all artist monetization transactions.

### 2. Tax & Identity Verification Requirements
• **IRS Tax Forms:** All artists must submit complete US IRS tax documentation before receiving payouts.
• **Stripe Connect KYC:** Identity verification (Know Your Customer) via Stripe Connect is strictly required for creator payouts.

### 3. Liability & FTC Compliance
• **Chargeback Responsibility:** Account holders bear full financial responsibility for customer chargebacks.
• **FTC Compliance:** Creators must comply with Federal Trade Commission (FTC) guidelines regarding sponsored content and ad compliance.
''',
    ),

    LegalDocumentSection(
      id: 'about',
      title: 'About Us & Company Overview',
      iconName: 'info',
      summary: 'US-based music platform connecting emerging artists with listeners, adhering to Apple & Google Play policies.',
      listenerContent: '''
# 6. About Us & Company Overview

**Last Updated: August 13, 2026**
**Entity: VibeSwipe LLC**

VibeSwipe is an interactive US based music platform that connects young emerging artists/ musicians to the general public. We strictly adhere to policies provided by Apple App store and the Google Play store.

---

### 1. Platform Overview
• **Mission:** VibeSwipe is an interactive, US-based music platform designed to connect young, emerging independent artists and musicians directly to the general public.
• **App Store Compliance:** VibeSwipe strictly adheres to mobile application guidelines and developer policies established by the Apple App Store and Google Play Store.
''',
      artistContent: '''
# 6. About Us & Company Overview (Creator Overview)

**Last Updated: August 13, 2026**
**Entity: VibeSwipe LLC**

VibeSwipe is an interactive US based music platform that connects young emerging artists/ musicians to the general public. We strictly adhere to policies provided by Apple App store and the Google Play store.

---

### 1. Empowering Emerging Musicians
• **US-Based Platform:** VibeSwipe bridges young emerging musical talent with global listeners through live performances and interactive discovery.
• **Store Guidelines:** Platform functionality, user safety, and payment features fully comply with Apple App Store and Google Play Store policies.
''',
    ),
  ];
}
