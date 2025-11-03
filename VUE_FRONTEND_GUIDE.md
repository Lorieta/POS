# Vue Frontend - Cloudinary Integration Guide

## Quick Setup for Vue Frontend

### 1. Install Required Dependencies

In your Vue frontend directory (`C:\Users\John Carlo\Vue\vue-frontend`):

```bash
npm install @apollo/client graphql
# or
yarn add @apollo/client graphql
```

### 2. Copy the Upload Helper

Copy `frontend/cloudinary_upload_helper.js` to your Vue project:

```bash
# From your Vue project directory
# Create the utils folder if it doesn't exist
mkdir -p src/utils
```

Then copy the content to: `src/utils/cloudinaryUpload.js`

### 3. Usage Example - Product Upload Form

```vue
<template>
  <div class="product-form">
    <h2>Create Product</h2>
    
    <form @submit.prevent="handleSubmit">
      <!-- Product Details -->
      <div class="form-group">
        <label>Product Name</label>
        <input 
          v-model="formData.name" 
          type="text" 
          required 
          placeholder="Enter product name"
        />
      </div>

      <div class="form-group">
        <label>Price</label>
        <input 
          v-model="formData.price" 
          type="number" 
          step="0.01" 
          required 
          placeholder="0.00"
        />
      </div>

      <div class="form-group">
        <label>Product Type</label>
        <input 
          v-model="formData.type" 
          type="text" 
          required 
          placeholder="e.g., Electronics, Food"
        />
      </div>

      <!-- Image Upload -->
      <div class="form-group">
        <label>Product Image</label>
        <input 
          type="file" 
          @change="handleFileChange" 
          accept="image/*"
          ref="fileInput"
        />
        
        <!-- Image Preview -->
        <div v-if="imagePreview" class="image-preview">
          <img :src="imagePreview" alt="Preview" />
          <button type="button" @click="clearImage">Remove</button>
        </div>
      </div>

      <!-- Submit Button -->
      <button 
        type="submit" 
        :disabled="uploading || !isFormValid"
        class="submit-btn"
      >
        <span v-if="uploading">Uploading... {{ uploadProgress }}%</span>
        <span v-else>Create Product</span>
      </button>

      <!-- Error Display -->
      <div v-if="error" class="error">{{ error }}</div>
    </form>
  </div>
</template>

<script>
import { ref, computed } from 'vue';
import { useMutation } from '@vue/apollo-composable';
import { gql } from '@apollo/client';
import { uploadToCloudinary } from '@/utils/cloudinaryUpload';
import { useApolloClient } from '@vue/apollo-composable';

const CREATE_PRODUCT_MUTATION = gql`
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
        productPrice
        productType
        imageUrl
      }
      errors
    }
  }
`;

export default {
  name: 'ProductForm',
  setup() {
    const { resolveClient } = useApolloClient();
    const { mutate: createProduct } = useMutation(CREATE_PRODUCT_MUTATION);

    const formData = ref({
      name: '',
      price: 0,
      type: ''
    });

    const selectedFile = ref(null);
    const imagePreview = ref(null);
    const uploading = ref(false);
    const uploadProgress = ref(0);
    const error = ref(null);
    const fileInput = ref(null);

    const isFormValid = computed(() => {
      return formData.value.name && 
             formData.value.price > 0 && 
             formData.value.type;
    });

    const handleFileChange = (event) => {
      const file = event.target.files[0];
      if (file) {
        selectedFile.value = file;
        
        // Create image preview
        const reader = new FileReader();
        reader.onload = (e) => {
          imagePreview.value = e.target.result;
        };
        reader.readAsDataURL(file);
      }
    };

    const clearImage = () => {
      selectedFile.value = null;
      imagePreview.value = null;
      if (fileInput.value) {
        fileInput.value.value = '';
      }
    };

    const handleSubmit = async () => {
      try {
        uploading.value = true;
        error.value = null;
        uploadProgress.value = 0;

        let imageSignedId = null;

        // Upload image if selected
        if (selectedFile.value) {
          uploadProgress.value = 50;
          const apolloClient = resolveClient();
          imageSignedId = await uploadToCloudinary(selectedFile.value, apolloClient);
          uploadProgress.value = 75;
        }

        // Create product
        const { data } = await createProduct({
          name: formData.value.name,
          productPrice: parseFloat(formData.value.price),
          productType: formData.value.type,
          imageSignedId: imageSignedId
        });

        uploadProgress.value = 100;

        if (data.createProduct.errors.length > 0) {
          error.value = data.createProduct.errors.join(', ');
        } else {
          alert('Product created successfully!');
          resetForm();
        }
      } catch (err) {
        console.error('Error creating product:', err);
        error.value = 'Failed to create product. Please try again.';
      } finally {
        uploading.value = false;
        uploadProgress.value = 0;
      }
    };

    const resetForm = () => {
      formData.value = {
        name: '',
        price: 0,
        type: ''
      };
      clearImage();
    };

    return {
      formData,
      selectedFile,
      imagePreview,
      uploading,
      uploadProgress,
      error,
      fileInput,
      isFormValid,
      handleFileChange,
      clearImage,
      handleSubmit
    };
  }
};
</script>

<style scoped>
.product-form {
  max-width: 500px;
  margin: 0 auto;
  padding: 20px;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 5px;
  font-weight: bold;
}

.form-group input {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
}

.image-preview {
  margin-top: 10px;
  position: relative;
}

.image-preview img {
  max-width: 200px;
  border-radius: 4px;
}

.image-preview button {
  margin-top: 10px;
  padding: 5px 10px;
  background: #dc3545;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.submit-btn {
  width: 100%;
  padding: 12px;
  background: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  font-size: 16px;
  cursor: pointer;
}

.submit-btn:disabled {
  background: #6c757d;
  cursor: not-allowed;
}

.error {
  margin-top: 10px;
  padding: 10px;
  background: #f8d7da;
  color: #721c24;
  border-radius: 4px;
}
</style>
```

### 4. Apollo Client Setup

Make sure your Apollo Client is configured in your Vue app (usually in `main.js` or `apollo.js`):

```javascript
import { ApolloClient, InMemoryCache, createHttpLink } from '@apollo/client/core';
import { createApolloProvider } from '@vue/apollo-option';

const httpLink = createHttpLink({
  uri: 'http://localhost:3000/graphql', // Your Rails GraphQL endpoint
});

const apolloClient = new ApolloClient({
  link: httpLink,
  cache: new InMemoryCache(),
});

const apolloProvider = createApolloProvider({
  defaultClient: apolloClient,
});

export default apolloProvider;
```

### 5. Test the Integration

1. **Start Rails backend:**
   ```bash
   cd /home/lorieta/POS
   rails s
   ```

2. **Start Vue frontend:**
   ```bash
   cd C:\Users\John Carlo\Vue\vue-frontend
   npm run dev
   ```

3. **Fill out the credentials in `/home/lorieta/POS/.env`:**
   - Get your Cloudinary credentials from: https://cloudinary.com/console
   - Replace `your_cloud_name_here`, `your_api_key_here`, `your_api_secret_here`

4. **Test uploading a product with an image!**

### 6. Environment Variables

Make sure to add `.env` to your `.gitignore`:

```bash
echo ".env" >> .gitignore
```

---

## Troubleshooting

### CORS Issues
If you get CORS errors, add to your Rails `config/application.rb`:

```ruby
config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://localhost:5173' # Your Vue dev server
    resource '*', headers: :any, methods: [:get, :post, :put, :patch, :delete, :options]
  end
end
```

And add to your `Gemfile`:
```ruby
gem 'rack-cors'
```

### MD5 Not Supported in Browser
If `crypto.subtle.digest('MD5')` doesn't work, install:
```bash
npm install blueimp-md5
```

And update the checksum function:
```javascript
import md5 from 'blueimp-md5';

async function calculateChecksum(arrayBuffer) {
  return btoa(md5(arrayBuffer, null, true));
}
```
