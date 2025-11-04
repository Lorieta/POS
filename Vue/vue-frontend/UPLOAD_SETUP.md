# Setup Guide for Product Upload with Cloudinary

## ✅ What's Been Added

### 1. **Add Product Button**
- Located next to the "Filter" button in ProductsGrid
- Opens a modal for adding new products with image upload

### 2. **AddProductModal Component** 
- Full-featured modal with form validation
- Real-time image preview
- Progress bar during upload
- Error handling

### 3. **Cloudinary Upload Helper**
- Located at: `src/utils/cloudinaryUpload.ts`
- Handles MD5 checksum calculation
- Manages direct upload to Cloudinary via Rails Active Storage

---

## 🚀 Setup Instructions

### 1. Configure Backend URL

The `.env` file has been created with:
```env
VITE_GRAPHQL_HTTP=http://localhost:3000/graphql
```

If your Rails backend is running on a different port, update this URL.

### 2. Configure Rails Backend

Make sure your Rails backend `.env` has Cloudinary credentials:

```bash
cd /home/lorieta/POS
nano .env
```

Add:
```env
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
ACTIVE_STORAGE_SERVICE=cloudinary
```

Get credentials from: https://cloudinary.com/console

### 3. Start Both Servers

**Terminal 1 - Rails Backend:**
```bash
cd /home/lorieta/POS
rails s
# Runs on http://localhost:3000
```

**Terminal 2 - Vue Frontend:**
```bash
cd /home/lorieta/POS/Vue/vue-frontend
npm run dev
# Runs on http://localhost:5173
```

---

## 📋 How It Works

### Upload Flow:

1. **User clicks "Add Product" button**
   - Modal opens with form fields

2. **User fills in product details:**
   - Name (required)
   - Description (optional)
   - Price (required)
   - Category (required)
   - Image (optional)

3. **User selects an image:**
   - Image preview appears
   - File is stored in component state

4. **User clicks "Add Product":**
   - Progress bar appears (0%)
   - MD5 checksum is calculated for the image
   - `CreateDirectUpload` mutation is sent to Rails (25%)
   - Rails returns signed URL and headers
   - Image is uploaded directly to Cloudinary (60%)
   - `CreateProduct` mutation is sent with signed ID (75%)
   - Product is created in database (100%)
   - New product appears in the grid immediately

---

## 🎨 Features

### Modal Features:
- ✅ Clean, modern UI
- ✅ Form validation
- ✅ Image preview with remove button
- ✅ Real-time upload progress
- ✅ Error handling with user-friendly messages
- ✅ Disabled state during upload
- ✅ ESC key to close (when not uploading)

### Upload Features:
- ✅ Direct upload to Cloudinary (files never touch Rails server)
- ✅ MD5 checksum validation
- ✅ File type validation (images only)
- ✅ Progress tracking
- ✅ Automatic retry on failure (via error message)

---

## 🧪 Testing

### Test the Upload Flow:

1. **Start both servers** (Rails + Vue)

2. **Open the Vue app:** http://localhost:5173

3. **Click "Add Product" button**

4. **Fill in the form:**
   ```
   Name: Test Book
   Description: A test product
   Price: 299
   Category: Books
   Image: [Select any image file]
   ```

5. **Click "Add Product"**
   - Watch the progress bar
   - Product should appear in the grid

6. **Check in Rails console:**
   ```bash
   rails c
   Product.last
   # Should show your new product with image attached
   ```

7. **Check in Cloudinary:**
   - Go to https://cloudinary.com/console/media_library
   - Your image should be there

---

## 🔧 Troubleshooting

### "Upload failed" error:
- Check that Rails backend is running on port 3000
- Verify `.env` has correct Cloudinary credentials
- Check Rails logs: `tail -f log/development.log`

### "Network error" or CORS issues:
- Ensure Rails allows CORS from Vue dev server
- Add to Rails `config/application.rb`:
  ```ruby
  config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins 'http://localhost:5173'
      resource '*', headers: :any, methods: [:get, :post, :put, :patch, :delete, :options]
    end
  end
  ```
- Add `gem 'rack-cors'` to Gemfile and run `bundle install`

### Image not showing in grid:
- Check that `imageUrl` field is returned in GraphQL response
- Verify ProductType has `image_url` field defined
- Check browser console for image loading errors

### Modal won't open:
- Check browser console for errors
- Verify AddProductModal is imported correctly
- Ensure Apollo Client is provided in main.ts

---

## 📝 Code Structure

```
Vue/vue-frontend/
├── src/
│   ├── component/
│   │   ├── ProductsGrid.vue        # Main grid with "Add Product" button
│   │   └── AddProductModal.vue     # Modal component (NEW)
│   ├── utils/
│   │   └── cloudinaryUpload.ts     # Upload helper (NEW)
│   ├── apollo.ts                   # Apollo Client config
│   └── main.ts                     # App entry point
├── .env                            # Environment variables (NEW)
└── package.json
```

---

## 🎯 Next Steps

1. ✅ Test the upload flow end-to-end
2. ✅ Add success notifications (optional)
3. ✅ Add loading state for product grid
4. ✅ Implement product editing (optional)
5. ✅ Add image optimization/resizing (optional)

---

## 📚 Related Documentation

- Main setup: `/home/lorieta/POS/VUE_FRONTEND_GUIDE.md`
- Quick reference: `/home/lorieta/POS/CLOUDINARY_QUICKSTART.md`
- Cloudinary docs: https://cloudinary.com/documentation
