#!/usr/bin/env python3
"""
Complete database initialization script
Creates all database schemas and seeds initial data with authentication
"""
import asyncio
import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.database.connection import init_db
from app.models.user import User, Role, UserRole
from app.models.service_category import ServiceCategory
from app.utils.password import hash_password
from app.models.form_field_config import FormFieldConfig, FieldType
from app.models.verification_checkpoint_config import VerificationCheckpointConfig, CheckpointType


async def create_admin_user():
    """Create admin user with authentication"""
    print("\n" + "="*60)
    print("👤 Creating Admin User with Authentication")
    print("="*60)
    
    # Check if admin exists
    admin = await User.find_one({"email": "admin@example.com"})
    
    if not admin:
        # Create admin user
        password_hash = hash_password("Pass@1234")
        
        admin = User(
            email="admin@example.com",
            passwordHash=password_hash,
            fullName="System Admin",
        )
        await admin.insert()
        print(f"✅ Admin user created: {admin.email}")
    else:
        print(f"ℹ️  Admin user already exists: {admin.email}")
        # Update password hash
        password_hash = hash_password("Pass@1234")
        admin.password_hash = password_hash
        await admin.save()
        print(f"✅ Updated admin password hash")
    
    # Check and create roles
    roles = await Role.find({"userId": str(admin.id)}).to_list()
    existing_roles = {role.role for role in roles}
    
    # Create ADMIN role if it doesn't exist
    if UserRole.ADMIN not in existing_roles:
        admin_role = Role(userId=str(admin.id), role=UserRole.ADMIN)
        await admin_role.insert()
        print(f"✅ Added ADMIN role")
    
    # Create MANAGER role if it doesn't exist
    if UserRole.MANAGER not in existing_roles:
        manager_role = Role(userId=str(admin.id), role=UserRole.MANAGER)
        await manager_role.insert()
        print(f"✅ Added MANAGER role")
    
    # Display final status
    final_roles = await Role.find({"userId": str(admin.id)}).to_list()
    role_names = [role.role.value for role in final_roles]
    print(f"\n📋 Admin User Details:")
    print(f"   Email: admin@example.com")
    print(f"   Password: Pass@1234")
    print(f"   Roles: {', '.join(role_names)}")
    print(f"   User ID: {admin.id}")


async def seed_service_categories():
    """Seed default service categories"""
    print("\n" + "="*60)
    print("📂 Seeding Service Categories")
    print("="*60)
    
    default_categories = [
        {"name": "Wedding Venues", "description": "Venues for wedding ceremonies and receptions"},
        {"name": "Conference Halls", "description": "Spaces for conferences and business meetings"},
        {"name": "Party Halls", "description": "Venues for parties and celebrations"},
        {"name": "Banquet Halls", "description": "Large halls for banquets and events"},
        {"name": "Outdoor Venues", "description": "Open-air venues for events"},
        {"name": "Restaurants", "description": "Restaurants that host events"},
        {"name": "Hotels", "description": "Hotel venues for events"},
        {"name": "Community Centers", "description": "Community centers for local events"},
    ]
    
    created_count = 0
    for category_data in default_categories:
        existing = await ServiceCategory.find_one({"name": category_data["name"]})
        if not existing:
            category = ServiceCategory(**category_data)
            await category.insert()
            print(f"✅ Created category: {category.name}")
            created_count += 1
        else:
            print(f"ℹ️  Category already exists: {category_data['name']}")
    
    print(f"\n📊 Total categories: {len(default_categories)} (Created: {created_count})")


async def seed_form_fields():
    """Seed default form field configurations"""
    print("\n" + "="*60)
    print("📝 Seeding Form Field Configurations")
    print("="*60)
    
    default_fields = [
        {
            "fieldKey": "title",
            "label": "Property/Venue Name",
            "fieldType": FieldType.TEXT,
            "isRequired": True,
            "isEnabled": True,
            "displayOrder": 0,
            "step": "basic_info",
            "placeholder": "Enter property name",
            "validation": {"maxLength": 100},
        },
        {
            "fieldKey": "description",
            "label": "Description",
            "fieldType": FieldType.TEXTAREA,
            "isRequired": True,
            "isEnabled": True,
            "displayOrder": 1,
            "step": "basic_info",
            "placeholder": "Describe your venue",
            "validation": {"maxLength": 1000},
        },
        {
            "fieldKey": "location",
            "label": "Location",
            "fieldType": FieldType.TEXT,
            "isRequired": True,
            "isEnabled": True,
            "displayOrder": 2,
            "step": "basic_info",
            "placeholder": "City, State",
        },
        {
            "fieldKey": "address",
            "label": "Full Address",
            "fieldType": FieldType.TEXTAREA,
            "isRequired": True,
            "isEnabled": True,
            "displayOrder": 3,
            "step": "basic_info",
            "placeholder": "Complete address",
        },
        {
            "fieldKey": "pincode",
            "label": "Pincode",
            "fieldType": FieldType.PINCODE,
            "isRequired": True,
            "isEnabled": True,
            "displayOrder": 4,
            "step": "basic_info",
            "placeholder": "Enter pincode",
        },
        {
            "fieldKey": "capacity",
            "label": "Guest Capacity",
            "fieldType": FieldType.NUMBER,
            "isRequired": True,
            "isEnabled": True,
            "displayOrder": 5,
            "step": "details",
            "placeholder": "Number of guests",
            "validation": {"min": 1},
        },
        {
            "fieldKey": "propertyType",
            "label": "Property Type",
            "fieldType": FieldType.DROPDOWN,
            "isRequired": True,
            "isEnabled": True,
            "displayOrder": 6,
            "step": "details",
            "options": ["Indoor", "Outdoor", "Both"],
        },
        {
            "fieldKey": "eventTypes",
            "label": "Event Types",
            "fieldType": FieldType.MULTISELECT,
            "isRequired": True,
            "isEnabled": True,
            "displayOrder": 7,
            "step": "details",
            "options": ["Wedding", "Conference", "Party", "Banquet", "Corporate", "Social"],
        },
        {
            "fieldKey": "amenities",
            "label": "Amenities",
            "fieldType": FieldType.MULTISELECT,
            "isRequired": False,
            "isEnabled": True,
            "displayOrder": 8,
            "step": "details",
            "options": ["Parking", "AC", "WiFi", "Catering", "Stage", "Sound System", "Projector", "Generator"],
        },
        {
            "fieldKey": "pricePerDay",
            "label": "Price Per Day (₹)",
            "fieldType": FieldType.NUMBER,
            "isRequired": True,
            "isEnabled": True,
            "displayOrder": 9,
            "step": "pricing",
            "placeholder": "Enter price",
            "validation": {"min": 0},
        },
    ]
    
    created_count = 0
    for field_data in default_fields:
        existing = await FormFieldConfig.find_one({"fieldKey": field_data["fieldKey"]})
        if not existing:
            field = FormFieldConfig(**field_data)
            await field.insert()
            print(f"✅ Created field: {field.label} ({field.fieldKey})")
            created_count += 1
        else:
            print(f"ℹ️  Field already exists: {field_data['label']}")
    
    print(f"\n📊 Total fields: {len(default_fields)} (Created: {created_count})")


async def seed_verification_checkpoints():
    """Seed default verification checkpoint configurations"""
    print("\n" + "="*60)
    print("✅ Seeding Verification Checkpoint Configurations")
    print("="*60)
    
    default_checkpoints = [
        {
            "checkpointKey": "venue_exists",
            "label": "Venue Exists at Location",
            "checkpointType": CheckpointType.BOOLEAN,
            "description": "Verify that the venue actually exists at the stated location",
            "isRequired": True,
            "isEnabled": True,
            "displayOrder": 10,
            "category": "Credibility",
        },
        {
            "checkpointKey": "details_accuracy",
            "label": "Details Accuracy",
            "checkpointType": CheckpointType.RATING,
            "description": "Rate the accuracy of the submitted venue details (1-5 stars)",
            "isRequired": True,
            "isEnabled": True,
            "displayOrder": 20,
            "category": "Credibility",
            "validation": {"min": 1, "max": 5},
        },
        {
            "checkpointKey": "overall_rating",
            "label": "Overall Venue Rating",
            "checkpointType": CheckpointType.RATING,
            "description": "Provide an overall rating for the venue's quality and suitability (1-5 stars)",
            "isRequired": True,
            "isEnabled": True,
            "displayOrder": 30,
            "category": "Credibility",
            "validation": {"min": 1, "max": 5},
        },
        {
            "checkpointKey": "capacity_verification",
            "label": "Capacity Verification",
            "checkpointType": CheckpointType.NUMBER,
            "description": "Verify the actual guest capacity of the venue",
            "isRequired": True,
            "isEnabled": True,
            "displayOrder": 40,
            "category": "Details",
            "placeholder": "Enter verified capacity",
        },
        {
            "checkpointKey": "amenities_verification",
            "label": "Amenities Verification",
            "checkpointType": CheckpointType.MULTISELECT,
            "description": "Confirm the availability and condition of listed amenities",
            "isRequired": True,
            "isEnabled": True,
            "displayOrder": 50,
            "category": "Details",
            "options": ["Parking Available", "AC", "Stage", "Catering", "WiFi", "Projector", "Sound System", "Generator", "Restrooms", "Security"],
        },
        {
            "checkpointKey": "location_accuracy",
            "label": "Location Accuracy",
            "checkpointType": CheckpointType.DROPDOWN,
            "description": "Confirm the accuracy of the venue's address and location on map",
            "isRequired": True,
            "isEnabled": True,
            "displayOrder": 60,
            "category": "Details",
            "options": ["Accurate", "Minor Discrepancy", "Major Discrepancy"],
        },
        {
            "checkpointKey": "safety_compliance",
            "label": "Safety & Compliance Check",
            "checkpointType": CheckpointType.DROPDOWN,
            "description": "Assess general safety measures and compliance with local regulations",
            "isRequired": True,
            "isEnabled": True,
            "displayOrder": 70,
            "category": "Safety",
            "options": ["Compliant", "Minor Issues", "Major Issues"],
        },
        {
            "checkpointKey": "photo_uploads",
            "label": "Upload Venue Photos",
            "checkpointType": CheckpointType.MULTI_IMAGE,
            "description": "Upload current photos of the venue (exterior, interior, key areas)",
            "isRequired": True,
            "isEnabled": True,
            "displayOrder": 80,
            "category": "Documentation",
        },
        {
            "checkpointKey": "video_uploads",
            "label": "Upload Venue Videos (Optional)",
            "checkpointType": CheckpointType.VIDEO,
            "description": "Upload short video clips of the venue",
            "isRequired": False,
            "isEnabled": True,
            "displayOrder": 90,
            "category": "Documentation",
        },
        {
            "checkpointKey": "additional_feedback",
            "label": "Additional Feedback",
            "checkpointType": CheckpointType.TEXTAREA,
            "description": "Provide any additional comments or observations about the venue",
            "isRequired": False,
            "isEnabled": True,
            "displayOrder": 100,
            "category": "Feedback",
            "validation": {"maxLength": 500},
        },
        {
            "checkpointKey": "recommendation",
            "label": "Verification Recommendation",
            "checkpointType": CheckpointType.DROPDOWN,
            "description": "Recommend whether to approve, reject, or request more info for the venue",
            "isRequired": True,
            "isEnabled": True,
            "displayOrder": 110,
            "category": "Feedback",
            "options": ["Approve", "Reject", "Request More Info"],
        },
    ]
    
    created_count = 0
    for checkpoint_data in default_checkpoints:
        existing = await VerificationCheckpointConfig.find_one({"checkpointKey": checkpoint_data["checkpointKey"]})
        if not existing:
            checkpoint = VerificationCheckpointConfig(**checkpoint_data)
            await checkpoint.insert()
            print(f"✅ Created checkpoint: {checkpoint.label} ({checkpoint.checkpointKey})")
            created_count += 1
        else:
            print(f"ℹ️  Checkpoint already exists: {checkpoint_data['label']}")
    
    print(f"\n📊 Total checkpoints: {len(default_checkpoints)} (Created: {created_count})")


async def main():
    """Main initialization function"""
    print("\n" + "="*60)
    print("🚀 Database Initialization Script")
    print("="*60)
    print("This script will:")
    print("  1. Initialize database connection")
    print("  2. Create admin user with authentication")
    print("  3. Seed service categories")
    print("  4. Seed form field configurations")
    print("  5. Seed verification checkpoint configurations")
    print("="*60)
    
    try:
        # Initialize database (creates all collections/schemas)
        print("\n📦 Initializing database connection...")
        await init_db()
        print("✅ Database initialized successfully")
        
        # Create admin user
        await create_admin_user()
        
        # Seed service categories
        await seed_service_categories()
        
        # Seed form fields
        await seed_form_fields()
        
        # Seed verification checkpoints
        await seed_verification_checkpoints()
        
        print("\n" + "="*60)
        print("✅ Database Initialization Complete!")
        print("="*60)
        print("\n📋 Summary:")
        print("  ✅ Database schemas created")
        print("  ✅ Admin user created with authentication")
        print("  ✅ Service categories seeded")
        print("  ✅ Form field configurations seeded")
        print("  ✅ Verification checkpoint configurations seeded")
        print("\n🔐 Admin Login Credentials:")
        print("  Email: admin@example.com")
        print("  Password: Pass@1234")
        print("\n🌐 Your application is ready to use!")
        print("="*60 + "\n")
        
    except Exception as e:
        print(f"\n❌ Error during initialization: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    asyncio.run(main())

