# Cloudinary Active Storage Setup Guide

## 🎯 Quick Start

### 1. Get Your Cloudinary Credentials

1. Sign up or log in to [Cloudinary](https://cloudinary.com/)
2. Go to your [Dashboard](https://cloudinary.com/console)
3. Copy your:
   - Cloud Name
   - API Key
   - API Secret

### 2. Configure Environment Variables

Create a `.env` file in the root directory:

```bash
cp .env.example .env
```

Then edit `.env` and add your Cloudinary credentials:

```env
CLOUDINARY_CLOUD_NAME=your_actual_cloud_name
CLOUDINARY_API_KEY=your_actual_api_key
CLOUDINARY_API_SECRET=your_actual_api_secret
ACTIVE_STORAGE_SERVICE=cloudinary
```

**Important:** Make sure `.env` is in your `.gitignore` to keep credentials secret!

### 3. Install Dependencies (Already Done ✅)

The required gems are already in your Gemfile:
- `cloudinary` (~> 2.4)
- `activestorage-cloudinary-service` (~> 0.2)

If needed, run:
```bash
bundle install
```

### 4. Start Your Server

```bash
rails s
```

## 📤 How to Upload Images via GraphQL

### Step 1: Create a Direct Upload

First, get the file metadata (see example below for how to get these values):

```graphql
mutation {
  createDirectUpload(
    input: {
      filename: "product-image.jpg"
      byteSize: 245123
      checksum: "abcd1234base64checksum=="
      contentType: "image/jpeg"
    }
  ) {
    directUpload {
      signedId
      url
      headers
      blobId
      filename
      byteSize
      checksum
      contentType
    }
    errors
  }
}
```

### Step 2: Upload the File

Use the `url` and `headers` from the response to upload your file via HTTP PUT request:

```javascript
// Example using fetch
const file = document.querySelector('input[type="file"]').files[0];

// First, create the direct upload
const directUploadResponse = await createDirectUploadMutation({
  filename: file.name,
  byteSize: file.size,
  checksum: await calculateChecksum(file),
  contentType: file.type
});

const { url, headers, signedId } = directUploadResponse.data.createDirectUpload.directUpload;

// Then, upload the actual file
await fetch(url, {
  method: 'PUT',
  headers: headers,
  body: file
});

// Now use the signedId to create the product
```

### Step 3: Create Product with Image

Once uploaded, use the `signedId` to attach the image to a product:

```graphql
mutation {
  createProduct(
    input: {
      name: "Delicious Pizza"
      productPrice: 12.99
      productType: "Food"
      imageSignedId: "eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJB..."
    }
  ) {
    product {
      id
      name
      productPrice
      productType
      image {
        url
      }
    }
    errors
  }
}
```

## 🛠️ Getting File Metadata

### Using Command Line (Linux/Mac)

```bash
FILE=path/to/your/image.jpg
BYTE_SIZE=$(stat -c%s "$FILE")
CHECKSUM=$(openssl dgst -md5 -binary "$FILE" | base64)
CONTENT_TYPE=$(file --brief --mime-type "$FILE")

echo "Byte Size: $BYTE_SIZE"
echo "Checksum: $CHECKSUM"
echo "Content Type: $CONTENT_TYPE"
```

### Using JavaScript

```javascript
async function getFileMetadata(file) {
  const checksum = await calculateMD5(file);
  
  return {
    filename: file.name,
    byteSize: file.size,
    checksum: checksum,
    contentType: file.type
  };
}

async function calculateMD5(file) {
  const buffer = await file.arrayBuffer();
  const hashBuffer = await crypto.subtle.digest('MD5', buffer);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  const hashBase64 = btoa(String.fromCharCode.apply(null, hashArray));
  return hashBase64;
}
```

## 🔄 Switching Between Local and Cloudinary

### For Development
```bash
# Use local storage
export ACTIVE_STORAGE_SERVICE=local

# Use Cloudinary
export ACTIVE_STORAGE_SERVICE=cloudinary
```

### For Production
Production is configured to use Cloudinary by default (see `config/environments/production.rb`).

## 📁 Current Configuration

### Storage Services (`config/storage.yml`)
- ✅ `local` - Disk storage in `/storage`
- ✅ `test` - Disk storage in `/tmp/storage`
- ✅ `cloudinary` - Cloudinary service

### Environment Configuration
- **Development** (`config/environments/development.rb`):
  - Default: `local`
  - Override with: `ACTIVE_STORAGE_SERVICE=cloudinary`

- **Production** (`config/environments/production.rb`):
  - Default: `cloudinary`
  - Override with: `ACTIVE_STORAGE_SERVICE=local`

## 🎨 Image Variants and Transformations

With Cloudinary, you can easily create image variants:

```ruby
# In your Product model or wherever needed
product.image.variant(
  resize_to_limit: [500, 500],
  format: :jpg,
  quality: 80
).processed.url
```

## 🔍 Viewing Your Images

Once uploaded to Cloudinary, you can:
1. View all uploads in your [Cloudinary Media Library](https://cloudinary.com/console/media_library)
2. Access images via URL: `product.image.url`
3. Use transformations in the URL for different sizes/formats

## 🐛 Troubleshooting

### Images not uploading to Cloudinary
- Check that `ACTIVE_STORAGE_SERVICE=cloudinary` is set
- Verify your Cloudinary credentials are correct
- Check Rails logs: `tail -f log/development.log`

### Direct upload fails
- Ensure the checksum is calculated correctly (MD5, base64 encoded)
- Verify byte_size matches the actual file size
- Check content_type is correct

### Images still saving locally
- Restart your Rails server after changing environment variables
- Verify the environment variable is loaded: `Rails.configuration.active_storage.service`

## 📚 Additional Resources

- [Active Storage Overview](https://edgeguides.rubyonrails.org/active_storage_overview.html)
- [Cloudinary Rails SDK](https://cloudinary.com/documentation/rails_integration)
- [Direct Upload Guide](https://edgeguides.rubyonrails.org/active_storage_overview.html#direct-uploads)
