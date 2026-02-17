# Setting Up Form Field Configurations

## Overview
The admin can now manage form fields that users fill when adding a venue. This allows you to customize which fields appear in the venue submission form.

## Step 1: Run Seed Script (Initialize Default Fields)

First, you need to populate the database with the default form fields that match your current form.

**On your server:**
```bash
ssh root@72.61.232.15
cd /var/www/eventorganising/backend
source venv/bin/activate
python scripts/seed_form_fields.py
```

This will create the following default fields matching your current form:
- **title** (Property/Venue Name) - text, required, basic_info
- **propertyType** (Property Type) - dropdown, required, basic_info  
- **eventTypes** (Event Types) - multiselect, required, basic_info
- **description** (Description) - textarea, required, basic_info
- **location** (Location) - text, required, location
- **address** (Address) - textarea, optional, location
- **pincode** (Pincode) - pincode, optional, location
- **capacity** (Capacity) - number, optional, location
- **price** (Price per Day) - number, required, location
- **amenities** (Amenities) - multiselect, optional, amenities
- **photos** (Photo URLs) - url, optional, amenities

## Step 2: Access Admin Form Fields Screen

1. Log in as admin
2. Go to Admin Dashboard
3. Scroll to "Form Field Configurations" section
4. Click "Manage" button
5. Or navigate directly to: `/admin/form-fields`

## Step 3: Manage Form Fields

From the Form Field Configurations screen, you can:

### View All Fields
- See all configured form fields
- View field details (type, required, step, etc.)
- See which fields are enabled/disabled

### Add New Field
- Click "Add Field" button
- Configure:
  - Field Key (unique identifier)
  - Label (display name)
  - Field Type (text, textarea, number, dropdown, multiselect, url, pincode)
  - Step (basic_info, location, amenities, review)
  - Required/Optional
  - Display Order
  - Placeholder & Hint
  - Options (for dropdowns/multiselects)

### Edit Existing Field
- Click the edit icon on any field card
- Modify any properties
- Field key cannot be changed (but other properties can)

### Enable/Disable Fields
- Toggle the switch on any field card
- Disabled fields won't appear in the form

### Delete Fields
- Click the delete icon
- Confirm deletion
- Warning: This will remove the field from the form

## Current Form Steps

The form has 4 steps:
1. **Basic Info** - Property name, type, event types, description
2. **Location** - Location, address, pincode, capacity, price
3. **Amenities** - Amenities, photos
4. **Review** - Review all information before submission

You can assign fields to any of these steps using the "Step" dropdown when adding/editing fields.

## Important Notes

⚠️ **Dynamic Form Rendering Not Yet Implemented**
- The form fields configuration is stored and can be managed
- However, the submission form (`submit_service_screen.dart`) still uses hardcoded fields
- To make the form dynamic, you'll need to implement dynamic form rendering (see FORM_FIELD_CONFIG_IMPLEMENTATION.md)

✅ **What Works Now:**
- Admin can manage form field configurations
- All CRUD operations (Create, Read, Update, Delete)
- Field configuration is stored in database
- API endpoints are ready

📝 **Next Step:**
To make the form actually use these configurations, you'll need to:
1. Modify `submit_service_screen.dart` to fetch and render fields dynamically
2. This is a complex task requiring significant refactoring

