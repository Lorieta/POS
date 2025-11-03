// app/javascript/helpers/cloudinary_upload.js
// Helper functions for uploading files to Cloudinary via Active Storage

/**
 * Calculate MD5 checksum of a file
 * @param {File} file - The file to calculate checksum for
 * @returns {Promise<string>} Base64 encoded MD5 checksum
 */
async function calculateChecksum(file) {
    const arrayBuffer = await file.arrayBuffer();
    const hashBuffer = await crypto.subtle.digest('MD5', arrayBuffer);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    const hashBase64 = btoa(String.fromCharCode(...hashArray));
    return hashBase64;
}

/**
 * Create a direct upload for a file
 * @param {File} file - The file to upload
 * @param {Function} graphqlMutation - Function to execute the GraphQL mutation
 * @returns {Promise<Object>} Direct upload response with signedId, url, headers
 */
async function createDirectUpload(file, graphqlMutation) {
    const checksum = await calculateChecksum(file);

    const mutation = `
    mutation CreateDirectUpload($input: CreateDirectUploadInput!) {
      createDirectUpload(input: $input) {
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
  `;

    const variables = {
        input: {
            filename: file.name,
            byteSize: file.size,
            checksum: checksum,
            contentType: file.type
        }
    };

    const response = await graphqlMutation(mutation, variables);

    if (response.data.createDirectUpload.errors.length > 0) {
        throw new Error(response.data.createDirectUpload.errors.join(', '));
    }

    return response.data.createDirectUpload.directUpload;
}

/**
 * Upload file to the direct upload URL
 * @param {File} file - The file to upload
 * @param {string} url - The direct upload URL
 * @param {Object} headers - Headers for the upload request
 * @returns {Promise<Response>} Fetch response
 */
async function uploadFile(file, url, headers) {
    const response = await fetch(url, {
        method: 'PUT',
        body: file,
        headers: headers
    });

    if (!response.ok) {
        throw new Error(`Upload failed: ${response.statusText}`);
    }

    return response;
}

/**
 * Complete file upload process (create direct upload + upload file)
 * @param {File} file - The file to upload
 * @param {Function} graphqlMutation - Function to execute GraphQL mutations
 * @returns {Promise<string>} The signed ID to use for attaching to models
 */
export async function uploadToCloudinary(file, graphqlMutation) {
    try {
        // Step 1: Create direct upload
        const directUpload = await createDirectUpload(file, graphqlMutation);

        // Step 2: Upload the actual file
        await uploadFile(file, directUpload.url, directUpload.headers);

        // Step 3: Return the signed ID for attaching to models
        return directUpload.signedId;
    } catch (error) {
        console.error('Upload failed:', error);
        throw error;
    }
}

/**
 * Upload file and create product in one go
 * @param {File} file - The image file to upload
 * @param {Object} productData - Product data (name, productPrice, productType)
 * @param {Function} graphqlMutation - Function to execute GraphQL mutations
 * @returns {Promise<Object>} Created product data
 */
export async function uploadAndCreateProduct(file, productData, graphqlMutation) {
    try {
        // Upload the image and get signed ID
        const signedId = await uploadToCloudinary(file, graphqlMutation);

        // Create product with the image
        const mutation = `
      mutation CreateProduct($input: CreateProductInput!) {
        createProduct(input: $input) {
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
    `;

        const variables = {
            input: {
                ...productData,
                imageSignedId: signedId
            }
        };

        const response = await graphqlMutation(mutation, variables);

        if (response.data.createProduct.errors.length > 0) {
            throw new Error(response.data.createProduct.errors.join(', '));
        }

        return response.data.createProduct.product;
    } catch (error) {
        console.error('Upload and create product failed:', error);
        throw error;
    }
}

/**
 * Example GraphQL mutation executor using fetch
 * You can replace this with your actual GraphQL client (Apollo, Relay, etc.)
 */
export async function executeGraphQLMutation(mutation, variables) {
    const response = await fetch('/graphql', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            // Add your auth token if needed
            // 'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({
            query: mutation,
            variables: variables
        })
    });

    if (!response.ok) {
        throw new Error(`GraphQL request failed: ${response.statusText}`);
    }

    return await response.json();
}

// ===== USAGE EXAMPLES =====

/*
// Example 1: Basic file upload
const fileInput = document.querySelector('input[type="file"]');
fileInput.addEventListener('change', async (e) => {
  const file = e.target.files[0];
  if (file) {
    try {
      const signedId = await uploadToCloudinary(file, executeGraphQLMutation);
      console.log('Upload successful! Signed ID:', signedId);
      // Now you can use this signedId to attach to a product
    } catch (error) {
      console.error('Upload failed:', error);
    }
  }
});

// Example 2: Upload and create product
const form = document.querySelector('#product-form');
form.addEventListener('submit', async (e) => {
  e.preventDefault();
  
  const fileInput = form.querySelector('input[type="file"]');
  const file = fileInput.files[0];
  
  const productData = {
    name: form.querySelector('[name="name"]').value,
    productPrice: parseFloat(form.querySelector('[name="price"]').value),
    productType: form.querySelector('[name="type"]').value
  };
  
  try {
    const product = await uploadAndCreateProduct(file, productData, executeGraphQLMutation);
    console.log('Product created with image:', product);
    // Redirect or show success message
  } catch (error) {
    console.error('Failed to create product:', error);
    // Show error message to user
  }
});

// Example 3: With progress tracking
async function uploadWithProgress(file, onProgress) {
  const signedId = await uploadToCloudinary(file, executeGraphQLMutation);
  onProgress(100);
  return signedId;
}

uploadWithProgress(file, (progress) => {
  console.log(`Upload progress: ${progress}%`);
  // Update progress bar UI
});
*/
