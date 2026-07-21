import datetime
import uuid
from flask import Blueprint, jsonify, request
from firebase_config import get_firestore_client

campaigns_bp = Blueprint('campaigns', __name__)

def _get_db():
    return get_firestore_client()

@campaigns_bp.route('/api/sponsors', methods=['GET'])
def get_sponsors():
    db = _get_db()
    docs = db.collection("sponsors").stream()
    sponsors = [d.to_dict() for d in docs]
    return jsonify({"sponsors": sponsors})

@campaigns_bp.route('/api/sponsors', methods=['POST'])
def create_sponsor():
    db = _get_db()
    data = request.json
    sponsor_id = str(uuid.uuid4())
    new_sponsor = {
        "id": sponsor_id,
        "name": data.get("name"),
        "email": data.get("email"),
        "phone": data.get("phone", ""),
        "createdAt": datetime.datetime.now().strftime("%Y-%m-%d"),
        "status": "Active"
    }
    db.collection("sponsors").document(sponsor_id).set(new_sponsor)
    return jsonify(new_sponsor), 201

@campaigns_bp.route('/api/campaigns', methods=['GET'])
def get_campaigns():
    db = _get_db()
    docs = db.collection("campaigns").stream()
    campaigns = [d.to_dict() for d in docs]
    return jsonify({"campaigns": campaigns})

@campaigns_bp.route('/api/campaigns', methods=['POST'])
def create_campaign():
    db = _get_db()
    data = request.json
    campaign_id = str(uuid.uuid4())
    new_campaign = {
        "id": campaign_id,
        "name": data.get("name"),
        "sponsorId": data.get("sponsorId"),
        "startDate": data.get("startDate"),
        "endDate": data.get("endDate"),
        "budget": data.get("budget", 0),
        "spent": 0,
        "targetAudience": data.get("targetAudience", ["All Listeners"]),
        "adPlacement": data.get("adPlacement", ["Home Banner"]),
        "status": data.get("status", "Active"),
        "bannerUrl": data.get("bannerUrl", "https://placehold.co/600x400/png?text=Ad"),
        "destinationUrl": data.get("destinationUrl", ""),
        "impressions": 0,
        "clicks": 0,
        "createdAt": datetime.datetime.now().strftime("%Y-%m-%d")
    }
    db.collection("campaigns").document(campaign_id).set(new_campaign)
    
    # If a notification was requested with the campaign
    if data.get("sendNotification"):
        notification_id = str(uuid.uuid4())
        new_notification = {
            "id": notification_id,
            "title": f"New Campaign: {new_campaign['name']}",
            "message": data.get("notificationMessage", "Check out our new sponsored campaign!"),
            "targetAudience": new_campaign['targetAudience'],
            "campaignId": new_campaign['id'],
            "createdAt": datetime.datetime.now().strftime("%Y-%m-%d"),
            "status": "Sent"
        }
        db.collection("notifications").document(notification_id).set(new_notification)
        
    return jsonify(new_campaign), 201

@campaigns_bp.route('/api/campaigns/<campaign_id>', methods=['PUT'])
def update_campaign(campaign_id):
    db = _get_db()
    data = request.json
    doc_ref = db.collection("campaigns").document(campaign_id)
    doc = doc_ref.get()
    if not doc.exists:
        return jsonify({"error": "Campaign not found"}), 404
    
    doc_ref.set(data, merge=True)
    updated_doc = doc_ref.get().to_dict()
    return jsonify(updated_doc)

@campaigns_bp.route('/api/campaigns/<campaign_id>', methods=['DELETE'])
def delete_campaign(campaign_id):
    db = _get_db()
    db.collection("campaigns").document(campaign_id).delete()
    return '', 204

# Public endpoints for app to fetch ads and log interactions
@campaigns_bp.route('/api/ads/active', methods=['GET'])
def get_active_ads():
    db = _get_db()
    placement = request.args.get('placement')
    docs = db.collection("campaigns").where("status", "==", "Active").stream()
    active_ads = [d.to_dict() for d in docs]
    if placement:
        active_ads = [c for c in active_ads if placement in c.get("adPlacement", [])]
    return jsonify({"ads": active_ads})

@campaigns_bp.route('/api/ads/<campaign_id>/view', methods=['POST'])
def log_ad_view(campaign_id):
    db = _get_db()
    doc_ref = db.collection("campaigns").document(campaign_id)
    doc = doc_ref.get()
    if not doc.exists:
        return jsonify({"error": "Ad not found"}), 404
    
    campaign = doc.to_dict()
    new_impressions = campaign.get("impressions", 0) + 1
    doc_ref.update({"impressions": new_impressions})
    return jsonify({"success": True, "impressions": new_impressions})

@campaigns_bp.route('/api/ads/<campaign_id>/click', methods=['POST'])
def log_ad_click(campaign_id):
    db = _get_db()
    doc_ref = db.collection("campaigns").document(campaign_id)
    doc = doc_ref.get()
    if not doc.exists:
        return jsonify({"error": "Ad not found"}), 404
    
    campaign = doc.to_dict()
    new_clicks = campaign.get("clicks", 0) + 1
    doc_ref.update({"clicks": new_clicks})
    return jsonify({"success": True, "clicks": new_clicks})

@campaigns_bp.route('/api/notifications', methods=['GET'])
def get_notifications():
    db = _get_db()
    docs = db.collection("notifications").stream()
    notifications = [d.to_dict() for d in docs]
    return jsonify({"notifications": notifications})
