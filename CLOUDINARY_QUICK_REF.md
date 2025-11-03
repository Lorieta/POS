# 🚀 Cloudinary Quick Reference Card

## ⚡ Quick Setup (3 Steps)

### 1. Create `.env` file
```bash
cp .env.example .env
# Edit .env and add your Cloudinary credentials
```

### 2. Add your Cloudinary credentials to `.env`
```env
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
ACTIVE_STORAGE_SERVICE=cloudinary
```

### 3. Restart Rails
```bash
rails s
```

---

## 📤 Upload Flow (GraphQL)

### Step 1: Create Direct Upload
```graphql
mutation {
  createDirectUpload(input: {
    filename: "product.jpg"
    byteSize: 245123
    checksum: "abcd1234=="
    contentType: "image/jpeg"
  }) {
    directUpload {
      signedId
      url
      headers
    }
    errors
  }
}
```

### Step 2: Upload File (HTTP PUT)
```javascript
await fetch(url, {
  method: 'PUT',
  body: file,
  headers: headers
});
```

### Step 3: Create Product with Image
```graphql
mutation {
  createProduct(input: {
    name: "Pizza"
    productPrice: 12.99
    productType: "Food"
    imageSignedId: "eyJfcmFpbHMi..."
  }) {
    product {
      id
      name
      imageUrl
    }
    errors
  }
}
```

---

## 🛠️ Get File Metadata

### Bash (Linux/Mac)
```bash
FILE=path/to/image.jpg
stat -c%s "$FILE"  # byte size
openssl dgst -md5 -binary "$FILE" | base64  # checksum
file --brief --mime-type "$FILE"  # content type
```

### JavaScript
```javascript
const checksum = await calculateChecksum(file);
const metadata = {
  filename: file.name,
  byteSize: file.size,
  checksum: checksum,
  contentType: file.type
};
```

---

## 🧪 Testing

### Test Page
Open in browser: `http://localhost:3000/cloudinary_test.html`

### GraphiQL
Open in browser: `http://localhost:3000/graphiql`

---

## 🔄 Switch Storage Service

```bash
# Use Cloudinary
export ACTIVE_STORAGE_SERVICE=cloudinary

# Use Local
export ACTIVE_STORAGE_SERVICE=local

# Restart server
rails s
```

---

## 📁 Key Files

| File | Purpose |
|------|---------|
| `.env` | Your Cloudinary credentials (DO NOT COMMIT!) |
| `config/storage.yml` | Storage service configuration |
| `app/graphql/mutations/create_direct_upload.rb` | Direct upload mutation |
| `app/graphql/mutations/create_product.rb` | Product creation with image |
| `app/javascript/helpers/cloudinary_upload.js` | Frontend helper functions |
| `public/cloudinary_test.html` | Test page |

---

## 🎯 Common Tasks

### Check Active Service
```ruby
Rails.configuration.active_storage.service
# => :cloudinary or :local
```

### Get Image URL
```ruby
product.image.url  # Cloudinary or local URL
```

### Image Variants (Cloudinary Transformations)
```ruby
product.image.variant(
  resize_to_limit: [500, 500],
  format: :jpg,
  quality: 80
).processed.url
```

---

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| Images save locally | Set `ACTIVE_STORAGE_SERVICE=cloudinary` and restart |
| "Invalid checksum" | Use MD5 + base64: `openssl dgst -md5 -binary file \| base64` |
| Upload fails | Check Cloudinary credentials in `.env` |
| Server won't start | Check for syntax errors, run `rails s` |

---

## 📚 Documentation

- Full Guide: `CLOUDINARY_SETUP.md`
- Cloudinary Dashboard: https://cloudinary.com/console
- Active Storage Docs: https://edgeguides.rubyonrails.org/active_storage_overview.html

---

## 💡 Tips

✅ `.env` is already in `.gitignore` - your secrets are safe!  
✅ Production defaults to Cloudinary automatically  
✅ Development defaults to local storage  
✅ Image URLs work automatically with both services  
✅ Use `imageSignedId` parameter in `createProduct` mutation  

---

**Need Help?** Check the full guide in `CLOUDINARY_SETUP.md`
