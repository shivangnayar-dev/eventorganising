#!/usr/bin/env python3
"""
Seed script to initialize default verification checkpoint configurations
"""
import asyncio
import sys
import os

# Add parent directory to path to import app modules
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.database.connection import init_db
from app.models.verification_checkpoint_config import VerificationCheckpointConfig, CheckpointType


async def seed_verification_checkpoints():
    """Seed default verification checkpoint configurations"""
    await init_db()
    
    default_checkpoints = [
        # Credibility Checkpoints
        {
            "checkpointKey": "venue_exists",
            "label": "Venue Exists at Location",
            "checkpointType": CheckpointType.BOOLEAN,
            "description": "Verify that the venue actually exists at the stated location",
            "isRequired": True,
            "isEnabled": True,
            "displayOrder": 10,
            "category": "credibility",
            "hint": "Visit the location and confirm the venue exists",
        },
        {
            "checkpointKey": "details_accuracy",
            "label": "Details Accuracy",
            "checkpointType": CheckpointType.DROPDOWN,
            "description": "Rate the accuracy of the submitted venue details",
            "isRequired": True,
            "isEnabled": True,
            "displayOrder": 20,
            "category": "credibility",
            "options": ["Fully Accurate", "Mostly Accurate", "Partially Accurate", "Inaccurate"],
            "hint": "Compare submitted details with actual venue",
        },
        {
            "checkpointKey": "overall_rating",
            "label": "Overall Venue Rating",
            "checkpointType": CheckpointType.RATING,
            "description": "Rate the overall quality and credibility of the venue (1-5 stars)",
            "isRequired": True,
            "isEnabled": True,
            "displayOrder": 30,
            "category": "credibility",
            "validation": {"min": 1, "max": 5},
            "hint": "Consider cleanliness, maintenance, and overall condition",
        },
        
        # Details Verification
        {
            "checkpointKey": "capacity_accurate",
            "label": "Capacity Matches Description",
            "checkpointType": CheckpointType.BOOLEAN,
            "description": "Verify that the stated capacity matches the actual venue capacity",
            "isRequired": True,
            "isEnabled": True,
            "displayOrder": 40,
            "category": "details",
            "hint": "Count or estimate actual seating/standing capacity",
        },
        {
            "checkpointKey": "amenities_verified",
            "label": "Amenities Verification",
            "checkpointType": CheckpointType.TEXTAREA,
            "description": "List which amenities are actually available and any missing ones",
            "isRequired": False,
            "isEnabled": True,
            "displayOrder": 50,
            "category": "details",
            "placeholder": "e.g., AC: Yes, WiFi: Yes, Parking: Limited",
            "hint": "Verify each listed amenity",
        },
        {
            "checkpointKey": "location_accurate",
            "label": "Location & Address Accuracy",
            "checkpointType": CheckpointType.BOOLEAN,
            "description": "Confirm the location and address are correct",
            "isRequired": True,
            "isEnabled": True,
            "displayOrder": 60,
            "category": "details",
            "hint": "Verify GPS coordinates and address match",
        },
        
        # Safety & Compliance
        {
            "checkpointKey": "safety_compliance",
            "label": "Safety & Compliance",
            "checkpointType": CheckpointType.DROPDOWN,
            "description": "Assess safety measures and regulatory compliance",
            "isRequired": True,
            "isEnabled": True,
            "displayOrder": 70,
            "category": "safety",
            "options": ["Fully Compliant", "Mostly Compliant", "Needs Improvement", "Non-Compliant"],
            "hint": "Check fire safety, building codes, accessibility",
        },
        {
            "checkpointKey": "safety_notes",
            "label": "Safety Observations",
            "checkpointType": CheckpointType.TEXTAREA,
            "description": "Document any safety concerns or observations",
            "isRequired": False,
            "isEnabled": True,
            "displayOrder": 80,
            "category": "safety",
            "placeholder": "Document safety issues, if any",
            "hint": "Be specific about any safety concerns",
        },
        
        # Visual Documentation
        {
            "checkpointKey": "venue_photos",
            "label": "Venue Photos",
            "checkpointType": CheckpointType.MULTI_IMAGE,
            "description": "Upload photos of the venue (exterior, interior, amenities)",
            "isRequired": True,
            "isEnabled": True,
            "displayOrder": 90,
            "category": "documentation",
            "hint": "Take clear photos showing venue condition",
        },
        {
            "checkpointKey": "venue_video",
            "label": "Venue Video Tour",
            "checkpointType": CheckpointType.VIDEO,
            "description": "Upload a video tour of the venue (optional but recommended)",
            "isRequired": False,
            "isEnabled": True,
            "displayOrder": 100,
            "category": "documentation",
            "hint": "Video helps verify venue authenticity",
        },
        
        # Additional Feedback
        {
            "checkpointKey": "additional_feedback",
            "label": "Additional Feedback",
            "checkpointType": CheckpointType.TEXTAREA,
            "description": "Any additional observations or feedback about the venue",
            "isRequired": False,
            "isEnabled": True,
            "displayOrder": 110,
            "category": "feedback",
            "placeholder": "Share any additional observations",
            "hint": "Include any relevant information not covered above",
        },
        {
            "checkpointKey": "recommendation",
            "label": "Verification Recommendation",
            "checkpointType": CheckpointType.DROPDOWN,
            "description": "Your recommendation based on verification",
            "isRequired": True,
            "isEnabled": True,
            "displayOrder": 120,
            "category": "feedback",
            "options": ["Approve", "Approve with Conditions", "Request More Info", "Reject"],
            "hint": "Final recommendation after completing all checks",
        },
    ]
    
    created_count = 0
    updated_count = 0
    
    for checkpoint_data in default_checkpoints:
        existing = await VerificationCheckpointConfig.find_one({"checkpointKey": checkpoint_data["checkpointKey"]})
        
        if existing:
            # Update existing checkpoint
            for key, value in checkpoint_data.items():
                if key != "checkpointKey":  # Don't update checkpointKey
                    setattr(existing, key, value)
            await existing.save()
            updated_count += 1
            print(f"✅ Updated checkpoint: {checkpoint_data['checkpointKey']}")
        else:
            # Create new checkpoint
            checkpoint = VerificationCheckpointConfig(**checkpoint_data)
            await checkpoint.insert()
            created_count += 1
            print(f"✅ Created checkpoint: {checkpoint_data['checkpointKey']}")
    
    print(f"\n📊 Summary:")
    print(f"   Created: {created_count} checkpoints")
    print(f"   Updated: {updated_count} checkpoints")
    print(f"   Total: {len(default_checkpoints)} checkpoints")
    print(f"\n✅ Verification checkpoint seeding completed!")


if __name__ == "__main__":
    asyncio.run(seed_verification_checkpoints())

