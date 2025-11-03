// Cloudinary Upload Helper for Vue.js Frontend
// Usage: import { uploadToCloudinary } from '@/utils/cloudinaryUpload'

import { gql } from '@apollo/client';

const CREATE_DIRECT_UPLOAD = gql`
  mutation CreateDirectUpload($filename: String!, $byteSize: Int!, $checksum: String!, $contentType: String) {
    createDirectUpload(
      filename: $filename
      byteSize: $byteSize
      checksum: $checksum
      contentType: $contentType
    ) {
      directUpload {
        signedId
        url
        headers
        blobId
      }
      errors
    }
  }
`;

/**
 * Calculate MD5 checksum and convert to base64
 * @param {ArrayBuffer} arrayBuffer - File content as ArrayBuffer
 * @returns {Promise<string>} Base64 encoded MD5 checksum
 */
async function calculateChecksum(arrayBuffer) {
    const hashBuffer = await crypto.subtle.digest('MD5', arrayBuffer);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    const hashBinary = String.fromCharCode.apply(null, hashArray);
    return btoa(hashBinary);
}

/**
 * Upload file to Cloudinary via Rails Active Storage
 * @param {File} file - The file to upload
 * @param {ApolloClient} apolloClient - Apollo client instance
 * @returns {Promise<string>} Signed ID for attaching to models
 */
export async function uploadToCloudinary(file, apolloClient) {
    try {
        // 1. Read file and calculate checksum
        const arrayBuffer = await file.arrayBuffer();
        const checksum = await calculateChecksum(arrayBuffer);

        // 2. Request direct upload URL from Rails
        const { data } = await apolloClient.mutate({
            mutation: CREATE_DIRECT_UPLOAD,
            variables: {
                filename: file.name,
                byteSize: file.size,
                checksum: checksum,
                contentType: file.type
            }
        });

        if (data.createDirectUpload.errors.length > 0) {
            throw new Error(data.createDirectUpload.errors.join(', '));
        }

        const { url, headers, signedId } = data.createDirectUpload.directUpload;

        // 3. Upload file to Cloudinary
        const uploadHeaders = new Headers();
        const headersObj = JSON.parse(headers);

        Object.entries(headersObj).forEach(([key, value]) => {
            uploadHeaders.append(key, value);
        });

        const uploadResponse = await fetch(url, {
            method: 'PUT',
            headers: uploadHeaders,
            body: file
        });

        if (!uploadResponse.ok) {
            throw new Error(`Upload failed with status: ${uploadResponse.status}`);
        }

        // 4. Return signed ID for use in createProduct or other mutations
        return signedId;
    } catch (error) {
        console.error('Cloudinary upload error:', error);
        throw error;
    }
}

/**
 * Upload multiple files to Cloudinary
 * @param {File[]} files - Array of files to upload
 * @param {ApolloClient} apolloClient - Apollo client instance
 * @param {Function} onProgress - Optional progress callback
 * @returns {Promise<string[]>} Array of signed IDs
 */
export async function uploadMultipleToCloudinary(files, apolloClient, onProgress = null) {
    const signedIds = [];
    const total = files.length;

    for (let i = 0; i < total; i++) {
        const signedId = await uploadToCloudinary(files[i], apolloClient);
        signedIds.push(signedId);

        if (onProgress) {
            onProgress((i + 1) / total * 100);
        }
    }

    return signedIds;
}
