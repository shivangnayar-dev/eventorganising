#!/usr/bin/env python3
"""
Seed script to initialize default form field configurations
"""
import asyncio
import sys
import os

# Add parent directory to path to import app modules
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.database.connection import init_db
from app.models.form_field_config import FormFieldConfig, FieldType


async def seed_form_fields():
    """Seed default form field configurations"""
    await init_db()
    
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
            "fieldKey": "propertyType",
            "label": "Property Type",
            "fieldType": FieldType.DROPDOWN,
            "isRequired": True,
            "isEnabled": True,
            "displayOrder": 1,
            "step": "basic_info",
            "options": [
                "Banquet Hall",
                "Outdoor Lawn",
                "Indoor Auditorium",
                "Rooftop Terrace",
                "Garden/Farmhouse",
                "Hotel Conference Room",
                "Wedding Palace",
                "Other",
            ],
            "placeholder": "Select property type",
        },
        {
            "fieldKey": "eventTypes",
            "label": "Event Types",
            "fieldType": FieldType.MULTISELECT,
            "isRequired": True,
            "isEnabled": True,
            "displayOrder": 2,
            "step": "basic_info",
            "options": [
                "Weddings",
                "Corporate Events",
                "Birthdays",
                "Festivals & Public",
                "Conferences",
                "Exhibitions",
                "Concerts",
            ],
            "hint": "Select all applicable event types",
        },
        {
            "fieldKey": "description",
            "label": "Description",
            "fieldType": FieldType.TEXTAREA,
            "isRequired": True,
            "isEnabled": True,
            "displayOrder": 3,
            "step": "basic_info",
            "placeholder": "Describe your venue/property",
            "hint": "Minimum 30 characters required",
            "validation": {"minLength": 30, "maxLength": 2000},
        },
        {
            "fieldKey": "location",
            "label": "Location",
            "fieldType": FieldType.TEXT,
            "isRequired": True,
            "isEnabled": True,
            "displayOrder": 0,
            "step": "location",
            "placeholder": "Enter location (City, State)",
            "validation": {"maxLength": 200},
        },
        {
            "fieldKey": "address",
            "label": "Address",
            "fieldType": FieldType.TEXTAREA,
            "isRequired": False,
            "isEnabled": True,
            "displayOrder": 1,
            "step": "location",
            "placeholder": "Enter full address",
            "validation": {"maxLength": 500},
        },
        {
            "fieldKey": "pincode",
            "label": "Pincode",
            "fieldType": FieldType.PINCODE,
            "isRequired": False,
            "isEnabled": True,
            "displayOrder": 2,
            "step": "location",
            "placeholder": "Enter pincode",
            "validation": {"pattern": "^[0-9]{6}$"},
        },
        {
            "fieldKey": "capacity",
            "label": "Capacity",
            "fieldType": FieldType.NUMBER,
            "isRequired": False,
            "isEnabled": True,
            "displayOrder": 3,
            "step": "location",
            "placeholder": "Enter capacity",
            "validation": {"minValue": 1, "maxValue": 100000},
        },
        {
            "fieldKey": "price",
            "label": "Price per Day",
            "fieldType": FieldType.NUMBER,
            "isRequired": True,
            "isEnabled": True,
            "displayOrder": 4,
            "step": "location",
            "placeholder": "Enter price",
            "validation": {"minValue": 0},
        },
        {
            "fieldKey": "amenities",
            "label": "Amenities",
            "fieldType": FieldType.MULTISELECT,
            "isRequired": False,
            "isEnabled": True,
            "displayOrder": 0,
            "step": "amenities",
            "options": [
                "Parking Available",
                "AC",
                "Stage",
                "Catering",
                "WiFi",
                "Projector",
                "Sound System",
                "Generator",
            ],
            "hint": "Select all available amenities",
        },
        {
            "fieldKey": "photos",
            "label": "Photo URLs",
            "fieldType": FieldType.URL,
            "isRequired": False,
            "isEnabled": True,
            "displayOrder": 1,
            "step": "amenities",
            "placeholder": "Enter photo URL",
            "hint": "You can add multiple photos",
        },
    ]
    
    created_count = 0
    updated_count = 0
    
    for field_data in default_fields:
        existing = await FormFieldConfig.find_one({"fieldKey": field_data["fieldKey"]})
        
        if existing:
            # Update existing field
            for key, value in field_data.items():
                if key != "fieldKey":  # Don't update fieldKey
                    setattr(existing, key, value)
            await existing.save()
            updated_count += 1
            print(f"✅ Updated field: {field_data['fieldKey']}")
        else:
            # Create new field
            field = FormFieldConfig(**field_data)
            await field.insert()
            created_count += 1
            print(f"✅ Created field: {field_data['fieldKey']}")
    
    print(f"\n📊 Summary:")
    print(f"   Created: {created_count} fields")
    print(f"   Updated: {updated_count} fields")
    print(f"   Total: {len(default_fields)} fields")
    print(f"\n✅ Form field seeding completed!")


if __name__ == "__main__":
    asyncio.run(seed_form_fields())

