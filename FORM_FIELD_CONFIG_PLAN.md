# Form Field Configuration Feature - Implementation Plan

## Overview
Allow admins to configure which fields are required/optional in the venue submission form. Changes should dynamically reflect in the frontend form.

## Architecture

### 1. Database Model (`FormFieldConfig`)
Store field configurations with:
- Field key (e.g., "title", "description", "location")
- Field label (display name)
- Field type (text, number, dropdown, multiselect, etc.)
- Is required (boolean)
- Is enabled/visible (boolean)
- Display order (for sorting)
- Validation rules (min length, max length, pattern, etc.)
- Options (for dropdowns/multiselects)

### 2. Field Types Supported
- `text` - Single line text
- `textarea` - Multi-line text
- `number` - Numeric input
- `dropdown` - Single selection dropdown
- `multiselect` - Multiple selection chips
- `url` - URL input for images
- `pincode` - Numeric pincode

### 3. Default Fields (Initial Configuration)
1. **title** - text, required
2. **propertyType** - dropdown, required
3. **eventTypes** - multiselect, required
4. **description** - textarea, required (min 30 chars)
5. **location** - text, required
6. **pincode** - pincode, optional
7. **address** - textarea, optional
8. **capacity** - number, optional
9. **price** - number, required
10. **amenities** - multiselect, optional
11. **photos** - url (multiple), optional

## Implementation Steps

### Phase 1: Backend
1. Create `FormFieldConfig` model
2. Add CRUD endpoints in admin routes
3. Add service methods in AdminService
4. Create seed script to initialize default field configurations

### Phase 2: Frontend - Admin UI
1. Create data models for FormFieldConfig
2. Add API methods to fetch/update form fields
3. Create admin screen to manage form fields (similar to service categories screen)
4. Add route in admin router

### Phase 3: Frontend - Dynamic Form
1. Create service to fetch form field configuration
2. Modify `submit_service_screen.dart` to:
   - Fetch field configuration on load
   - Dynamically render fields based on configuration
   - Apply validation rules from configuration
   - Only show enabled fields
   - Respect display order

## Data Structure

```python
# FormFieldConfig Model
{
  "id": "string",
  "fieldKey": "title",  # Unique identifier
  "label": "Property/Venue Name",
  "fieldType": "text",
  "isRequired": true,
  "isEnabled": true,
  "displayOrder": 0,
  "validation": {
    "minLength": null,
    "maxLength": 100,
    "pattern": null
  },
  "options": null,  # For dropdowns/multiselects
  "placeholder": "Enter property name",
  "hint": null,
  "createdAt": "datetime",
  "updatedAt": "datetime"
}
```

## API Endpoints

### GET /api/admin/form-fields
Get all form field configurations

### GET /api/admin/form-fields/{id}
Get single form field configuration

### POST /api/admin/form-fields
Create new form field configuration

### PUT /api/admin/form-fields/{id}
Update form field configuration

### DELETE /api/admin/form-fields/{id}
Delete form field configuration

### GET /api/service/form-fields (Public)
Get active form field configurations for submission form

## Validation Rules
- Field key must be unique
- Cannot delete required fields (or show warning)
- Cannot disable required fields (or auto-set as optional)
- Display order must be unique (or auto-assign)

## UI Features (Admin Screen)
- List all form fields with their current status
- Enable/disable toggle for each field
- Edit field properties (label, required, validation)
- Reorder fields (drag & drop or up/down arrows)
- Add custom fields
- Preview form layout
- Reset to defaults option

