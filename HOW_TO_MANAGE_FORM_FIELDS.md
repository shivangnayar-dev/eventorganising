# How to Manage Form Fields in Admin Panel

## ✅ What You Can Do

The admin panel allows you to **fully manage** all form fields that users see when adding a venue:

### 1. **View All Fields**
- See all configured form fields in expandable cards
- View field details (type, step, required, validation, options, etc.)
- Fields are organized by their step (Basic Info, Location, Amenities)

### 2. **Edit Existing Fields** ✏️
- Click the **Edit** icon (pencil) on any field card
- Modify any property:
  - Label (display name)
  - Field Type (text, textarea, number, dropdown, multiselect, url, pincode)
  - Required/Optional
  - Enabled/Disabled
  - Step assignment (basic_info, location, amenities)
  - Display Order
  - Placeholder text
  - Hint text
  - Options (for dropdowns/multiselects)
  - Validation rules
- **Note:** Field Key cannot be changed (it's the unique identifier)

### 3. **Delete Fields** 🗑️
- Click the **Delete** icon (trash) on any field card
- Confirm deletion
- **Warning:** This permanently removes the field from the form configuration

### 4. **Enable/Disable Fields** 🔄
- Toggle the **Switch** on any field card
- Disabled fields won't appear in the form (but data is preserved)
- Useful for temporarily hiding fields without deleting them

### 5. **Add New Fields** ➕
- Click the **"Add Field"** button (floating action button or app bar button)
- Configure:
  - **Field Key** (unique identifier, e.g., "customField")
  - **Label** (display name, e.g., "Custom Field Name")
  - **Field Type** (text, textarea, number, dropdown, multiselect, url, pincode)
  - **Step** (basic_info, location, amenities, review)
  - **Required/Optional**
  - **Display Order** (controls field order within a step)
  - **Placeholder** text
  - **Hint** text
  - **Options** (for dropdowns/multiselects - one per line)
  - **Validation** rules

## 📍 How to Access

1. **Log in as Admin** (admin@example.com / Pass@1234)
2. **Go to Admin Dashboard** (`/dashboard`)
3. **Scroll to "Form Field Configurations" section**
4. **Click "Manage" button** or use "Manage Fields" in section header
5. **Or navigate directly to:** `/admin/form-fields`

## 🚀 First-Time Setup

Before you can see and manage fields, you need to populate the database with default fields:

### On Your Server:
```bash
ssh root@72.61.232.15
cd /var/www/eventorganising/backend
source venv/bin/activate
python scripts/seed_form_fields.py
```

This creates 11 default fields matching your current form:
- **Step 1 (Basic Info):** title, propertyType, eventTypes, description
- **Step 2 (Location):** location, address, pincode, capacity, price
- **Step 3 (Amenities):** amenities, photos

## 📋 Current Form Steps

The form has 4 steps (steps are fixed, but you can assign fields to any step):

1. **Basic Info** (`basic_info`) - Property name, type, event types, description
2. **Location** (`location`) - Location, address, pincode, capacity, price
3. **Amenities** (`amenities`) - Amenities, photos
4. **Review** (`review`) - Review all information (auto-generated, no fields)

**Note:** You can assign fields to any of these steps when adding/editing fields. Steps themselves are fixed (they represent the form flow).

## ⚠️ Important Notes

### Dynamic Form Rendering
- The form field configurations are stored in the database
- However, the actual venue submission form (`submit_service_screen.dart`) currently uses **hardcoded fields**
- To make the form **actually use** these configurations, you'll need to implement dynamic form rendering
- This is a complex task requiring significant refactoring of the submission form

### What Works Now
✅ Admin can manage form field configurations  
✅ All CRUD operations (Create, Read, Update, Delete)  
✅ Field configuration is stored in database  
✅ API endpoints are ready  
✅ Admin UI is fully functional  

### What's Next
🔨 Modify `submit_service_screen.dart` to:
- Fetch form field configurations from API
- Dynamically render fields based on configuration
- Apply validation rules from configuration
- Order fields by `displayOrder` within each step

## 🎯 Example: Modifying a Field

Let's say you want to change "Property/Venue Name" to "Business Name":

1. Go to Admin Dashboard → Form Field Configurations
2. Find the "Property/Venue Name" field card
3. Click the **Edit** icon (pencil)
4. Change the **Label** from "Property/Venue Name" to "Business Name"
5. Click **Save**
6. The change is saved to the database

(Note: The form won't reflect this change until dynamic rendering is implemented)

## 🎯 Example: Adding a New Field

Let's say you want to add a "Contact Phone" field:

1. Go to Admin Dashboard → Form Field Configurations
2. Click **"Add Field"** button
3. Fill in:
   - **Field Key:** `contactPhone`
   - **Label:** `Contact Phone`
   - **Field Type:** `text`
   - **Step:** `basic_info`
   - **Required:** Yes
   - **Placeholder:** `Enter contact phone number`
4. Click **Save**
5. The new field is added to the database

(Note: The form won't show this field until dynamic rendering is implemented)

