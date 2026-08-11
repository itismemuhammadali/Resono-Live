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
      summary: 'Account creation, age eligibility, user conduct, and platform rules.',
      listenerContent: '''
# 1. Terms & Conditions (Listener Edition)

**Last Updated: August 11, 2026**
**Entity: VibeSwipe LLC**

Welcome to VibeSwipe. By creating an account, accessing, or using our mobile application, you agree to be bound by these Terms & Conditions.

---

### 1. Account & Registration
• **Age Requirements:** You must be at least 13 years of age to use VibeSwipe. Minors between 13 and 18 must have parental or legal guardian consent.
• **Verification:** Accounts require valid OTP email verification via Firebase Authentication. You agree to provide accurate and truthful account details.
• **Security:** You are responsible for safeguarding your credentials and account access.

### 2. Platform Purpose
VibeSwipe is a music discovery, streaming, and artist-listener engagement platform. As a Listener, you can stream live audio/video performances, interact via live chat, send Super Chats, purchase tickets for exclusive paid streams, and tip performing artists.

### 3. Listener Code of Conduct
You agree **NOT** to:
• Harass, abuse, stalk, or send hate speech to artists, performers, or other listeners.
• Use automated bots, scrapers, or unauthorized tools to record, download, or re-distribute stream content.
• Attempt payment fraud, chargeback exploitation, or unauthorized account sharing.
• Post unauthorized commercial advertising, spam, or malicious links in live chat sessions.

### 4. Account Termination
VibeSwipe reserves the right to suspend or terminate accounts that violate these Terms or engage in fraudulent activities without prior notice.
''',
      artistContent: '''
# 1. Terms & Conditions (Artist & Performer Edition)

**Last Updated: August 11, 2026**
**Entity: VibeSwipe LLC**

Welcome to the VibeSwipe Creator Community. By registering as an Artist on VibeSwipe, you accept these Terms & Conditions.

---

### 1. Artist Eligibility & Monetization Verification
• **Age Eligibility:** Artists accepting payouts or tips must be at least 18 years of age or have a legally recognized parent/guardian manage their Stripe Connect account.
• **KYC & Verification:** Payout eligibility requires identity verification (KYC) processed via Stripe Connect.

### 2. Platform Role & Rights
VibeSwipe provides broadcasting, ticket sales, tipping, and analytics tools. You retain ownership of your original music and audio-visual recordings, while granting VibeSwipe a non-exclusive license to host, stream, and promote your content.

### 3. Artist Conduct & Circumvention Rules
Artists agree **NOT** to:
• Direct listeners off-platform to bypass VibeSwipe ticket fees or Stripe payment processing.
• Broadcast explicit, non-consensual, hate-speech, violent, or illegal content.
• Stream pre-recorded audio or video while representing it as a live performance.
• Use fake accounts or automated bots to inflate viewer counts, likes, or tips.

### 4. Account Suspension & Penalties
Violations of platform rules may result in immediate stream termination, temporary payout holds, or permanent account bans.
''',
    ),

    LegalDocumentSection(
      id: 'privacy',
      title: 'Privacy Policy',
      iconName: 'shield',
      summary: 'Data collection, storage, third-party integrations, and privacy rights.',
      listenerContent: '''
# 2. Privacy Policy

**Last Updated: August 11, 2026**
**Entity: VibeSwipe LLC**

Your privacy is paramount at VibeSwipe. This policy outlines how we collect, store, process, and protect your information.

---

### 1. Information We Collect
• **Account Data:** Name, email address, profile picture, phone number (OTP), role selection.
• **Payment Information:** Credit/debit card tokens processed securely via Stripe. We do NOT store full credit card numbers on our servers.
• **Usage Data:** Streaming watch time, liked tracks, saved performances, search queries, and engagement stats.
• **Device Data:** IP address, OS version, device model, notification tokens (FCM), unique device identifiers.

### 2. Third-Party Integrations & Processing
We integrate trusted third-party services to deliver core features:
• **Firebase (Google Cloud):** User authentication, Firestore database, Cloud Functions, notification routing.
• **Stripe Inc.:** Secure payment sheet processing, ticket checkout, tipping.
• **Agora.io:** Real-time low-latency live audio and video streaming backend.
• **Google & Apple Sign-In:** Federated authentication options.

### 3. Data Retention & Deletion Rights
• You have the right to request deletion of your account and personal data at any time through Privacy Settings or by contacting `privacy@vibeswipe.com`.
• Data is retained only as long as necessary to provide service and fulfill legal compliance obligations.
''',
      artistContent: '''
# 2. Privacy Policy (Artist & Creator Data)

**Last Updated: August 11, 2026**
**Entity: VibeSwipe LLC**

This Privacy Policy details creator data handling, payout verification, and broadcast analytics logging.

---

### 1. Artist Data Collected
• **Identity & Financial Data:** Legal name, tax details, bank account info, SSN/EIN (collected directly by Stripe Connect for identity verification and tax reporting).
• **Media & Stream Logs:** Live stream duration, audio/video bitrates, live viewer counts, chat transcripts, tip records.
• **Device Permissions:** Camera and microphone access strictly when initiating a live stream session.

### 2. Identity Verification Disclosures
Financial payouts and creator onboarding are powered by Stripe Connect. Stripe collects verification documents in compliance with Anti-Money Laundering (AML) and Know-Your-Customer (KYC) regulations.

### 3. Creator Analytics & Privacy Rights
Artists can view earnings, viewer stats, and payouts in the Artist Dashboard. Requests for full data exports or account purging can be submitted to `privacy@vibeswipe.com`.
''',
    ),

    LegalDocumentSection(
      id: 'content',
      title: 'Content & Service Terms',
      iconName: 'music_note',
      summary: 'Music licensing, live streaming rules, subscriptions, and refund rules.',
      listenerContent: '''
# 3. Content & Service Terms

**Last Updated: August 11, 2026**

---

### 1. Digital Content Access
• Purchasing a paid performance ticket grants you a non-transferable, personal license to watch the designated live stream or replay.
• Stream access does not convey copyright or downloading rights.

### 2. Tips & Super Chats
• Tips and Super Chat payments sent to artists are voluntary donations to support creators.
• **All tips and Super Chats are non-refundable** once processed, except in cases of verified platform system errors or fraudulent charges.

### 3. Live Streaming Quality
Streaming quality depends on local network connection and broadband capabilities. VibeSwipe is not liable for buffering caused by user internet degradation.
''',
      artistContent: '''
# 3. Content & Service Terms (Creator Media Rights)

**Last Updated: August 11, 2026**

---

### 1. Content Ownership & Warranties
• You warrant that you own or hold all required synchronization, mechanical, master recording, and performance rights for all music, clips, and visuals broadcast or uploaded to VibeSwipe.
• You grant VibeSwipe a worldwide, non-exclusive, royalty-free license to transmit, stream, cache, and display promotional clips of your performances across the platform.

### 2. Live Broadcast Rules
• Camera & Mic streaming must adhere to community standards.
• No broadcasting of copyrighted background tracks without valid authorization.
• Session timeouts and stream auto-ending apply if no active audio feed is detected for over 15 minutes.
''',
    ),

    LegalDocumentSection(
      id: 'copyright',
      title: 'Copyright & DMCA Policy',
      iconName: 'copyright',
      summary: 'Intellectual property protection, DMCA takedown requests, and counter-notices.',
      listenerContent: '''
# 4. Copyright & DMCA Policy

**Last Updated: August 11, 2026**

VibeSwipe respects intellectual property rights and complies with the Digital Millennium Copyright Act (DMCA).

---

### 1. Reporting Infringements
If you believe content on VibeSwipe infringes your copyright, submit a formal DMCA Takedown Notice to our Designated Copyright Agent:

**Designated Agent:** VibeSwipe Legal Dept.  
**Email:** `copyright@vibeswipe.com`  
**Address:** VibeSwipe LLC, 100 Main Street, Suite 400, Wilmington, DE 19801  

### 2. Notice Requirements
Your takedown request must include:
1. Physical or electronic signature of the copyright owner or authorized representative.
2. Identification of the copyrighted work claimed to have been infringed.
3. Exact URL or link to the infringing stream or performance on VibeSwipe.
4. Your contact details (email, phone number, physical address).
5. A statement of good faith belief that the use is unauthorized.
6. A statement under penalty of perjury that the information in the notice is accurate.
''',
      artistContent: '''
# 4. Copyright & DMCA Policy (Artist Rights & Counter-Notices)

**Last Updated: August 11, 2026**

---

### 1. Artist IP Responsibility
Artists are strictly liable for ensuring all uploaded tracks, cover images, and live stream broadcasts do not violate third-party trademarks, copyrights, or publisher licenses.

### 2. Counter-Notice Procedure
If your stream or performance is removed due to a DMCA notice and you believe this was an error or misidentification, you may submit a Counter-Notice containing:
1. Identification of the removed material and its location prior to removal.
2. A statement under penalty of perjury that you have a good faith belief the material was removed by mistake.
3. Your consent to the jurisdiction of the Federal District Court.
4. Your physical/electronic signature and contact details.

### 3. Repeat Infringer Policy
VibeSwipe enforces a strict "three-strike" repeat infringer policy. Accounts receiving 3 valid copyright takedown notices will face permanent termination and forfeiture of pending unverified payouts.
''',
    ),

    LegalDocumentSection(
      id: 'payments',
      title: 'Payment & Payout Policy',
      iconName: 'payments',
      summary: 'Platform fees, Stripe Connect integration, tipping, payouts, and chargebacks.',
      listenerContent: '''
# 5. Payment & Payout Policy

**Last Updated: August 11, 2026**

---

### 1. Payment Methods & Processing
• All payments (ticket purchases, tips, Super Chats) are securely processed via **Stripe Inc.**.
• Charges on your bank or credit card statement will appear as `VIBESWIPE* ARTIST_NAME` or `VIBESWIPE LLC`.

### 2. Ticket Refunds
• Ticket sales for live performances are final.
• Refunds are automatically issued only if an artist cancels a scheduled paid performance without re-scheduling within 48 hours.

### 3. Disputes & Chargebacks
Unreasonable chargeback submissions without contacting VibeSwipe support first may lead to account suspension.
''',
      artistContent: '''
# 5. Payment & Payout Policy (Creator Earnings)

**Last Updated: August 11, 2026**

---

### 1. Platform Fee Structure
VibeSwipe maintains a transparent revenue share model:
• **Ticket Sales & Paid Access:** 85% to Artist / 15% VibeSwipe Platform Fee.
• **Tips & Super Chats:** 85% to Artist / 15% VibeSwipe Platform Fee.

### 2. Stripe Connect & Payout Transfers
• Earnings are accumulated in your connected Stripe account.
• Standard rolling payout schedules (e.g. 2-day rolling transfers) are managed directly via Stripe Connect to your linked bank account or debit card.

### 3. Payout Holds & Chargebacks
• If a listener files a chargeback, Stripe holds the disputed amount pending investigation.
• Fraudulent earnings or suspicious bot activity will result in frozen payouts.
''',
    ),

    LegalDocumentSection(
      id: 'about',
      title: 'About VibeSwipe',
      iconName: 'info',
      summary: 'Company overview, platform purpose, mission statement, and store credentials.',
      listenerContent: '''
# 6. About VibeSwipe

**VibeSwipe LLC**  
*Connecting Independent Artists & Passionate Listeners Worldwide*

---

### Mission
VibeSwipe is designed to revolutionize music discovery and live performance engagement. We empower independent musicians to broadcast their talent live, connect directly with fans, and build sustainable music careers.

### Core Features
• **Swipe Discovery Feed:** Discover new artists with interactive audio/video previews.
• **Live Performances:** HD low-latency streams powered by Agora.io.
• **Direct Support:** Support your favorite performers with instant tips and Super Chats.
• **Community Discussions:** Engage in genre-specific discussions with fellow music lovers.

### Corporate Info
• **Company Name:** VibeSwipe LLC  
• **Support Email:** `support@vibeswipe.com`  
• **Website:** `https://vibeswipe.com`  
''',
      artistContent: '''
# 6. About VibeSwipe (Creator Platform Overview)

**VibeSwipe LLC**

---

### Creator Philosophy
VibeSwipe puts creators first. We eliminate middleman barriers, providing artists with professional live broadcasting tools, transparent monetization via Stripe Connect, and direct fan engagement.

### Business & Store Information
• **Legal Entity:** VibeSwipe LLC  
• **Developer Contact:** `developer@vibeswipe.com`  
• **App Store Category:** Music & Entertainment  
• **Headquarters:** Wilmington, Delaware, USA  
''',
    ),
  ];
}
