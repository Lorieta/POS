# Cloudinary Quick Reference

## Setup Checklist

### Backend (Rails) ✅
- [x] Cloudinary gems installed (`cloudinary`, `activestorage-cloudinary-service`)
- [x] Storage configuration in `config/storage.yml`
- [x] GraphQL mutations ready (`CreateDirectUpload`, `CreateProduct`)
- [ ] **TODO: Add your credentials to `.env` file**

### Frontend (Vue)
- [ ] Install dependencies: `@apollo/client`, `graphql`
- [ ] Copy `frontend/cloudinary_upload_helper.js` to Vue project
- [ ] Configure Apollo Client
- [ ] Implement upload form

---

## How It Works

```
1. User selects image in Vue frontend
   ↓
2. Calculate checksum (MD5 in base64)
   ↓
3. Call CreateDirectUpload mutation → Get signed_id & upload URL
   ↓
4. Upload file directly to Cloudinary
   ↓
5. Call CreateProduct mutation with signed_id
   ↓
6. Rails attaches image to Product model
```

---

## Essential Code Snippets

### Frontend: Upload Image

```javascript
import { uploadToCloudinary } from '@/utils/cloudinaryUpload';

// In your component
const signedId = await uploadToCloudinary(file, apolloClient);
```

### GraphQL: Create Product with Image

```graphql
mutation CreateProduct(
  $name: String!
  $productPrice: Float!
  $productType: String!
  $imageSignedId: String
) {
  createProduct(
    name: $name
    productPrice: $productPrice
    productType: $productType
    imageSignedId: $imageSignedId
  ) {
    product {
      id
      name
      imageUrl
    }
    errors
  }
}
```

### Backend: Get Image URL

In your GraphQL type (`app/graphql/types/product_type.rb`):

```ruby
field :image_url, String, null: true

def image_url
  object.image.attached? ? Rails.application.routes.url_helpers.url_for(object.image) : nil
end
```

---

## Commands

### Start Backend
```bash
cd /home/lorieta/POS
rails s
```

### Start Frontend
```bash
cd C:\Users\John Carlo\Vue\vue-frontend
npm run dev
```

### Test in GraphiQL
Visit: http://localhost:3000/graphiql

---

## Environment Variables (`.env`)

```bash
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
ACTIVE_STORAGE_SERVICE=cloudinary
```

Get from: https://cloudinary.com/console

---

## File Locations

- **Backend Config**: `/home/lorieta/POS/config/storage.yml`
- **Upload Helper**: `/home/lorieta/POS/frontend/cloudinary_upload_helper.js`
- **Environment**: `/home/lorieta/POS/.env`
- **Mutations**: `/home/lorieta/POS/app/graphql/mutations/`
- **Full Guide**: `/home/lorieta/POS/VUE_FRONTEND_GUIDE.md`

---

## Next Steps

1. ✅ Update `.env` with Cloudinary credentials
2. ✅ Copy upload helper to Vue project
3. ✅ Test CreateDirectUpload mutation in GraphiQL
4. ✅ Implement product form in Vue
5. ✅ Test end-to-end upload flow
