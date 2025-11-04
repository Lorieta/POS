// Cloudinary Upload Helper for Vue.js Frontend
// Usage: import { uploadToCloudinary } from '@/utils/cloudinaryUpload'

import SparkMD5 from 'spark-md5';
import { CREATE_DIRECT_UPLOAD_MUTATION } from '@/graphql';

/**
 * Convert a hex digest to base64 encoding for Active Storage.
 */
function hexToBase64(hex: string): string {
    const matches = hex.match(/.{1,2}/g) ?? [];
    const bytes = matches.map((byte) => String.fromCharCode(parseInt(byte, 16))).join('');
    return btoa(bytes);
}

/**
 * Calculate MD5 checksum of a file buffer and encode as base64.
 */
function calculateChecksum(arrayBuffer: ArrayBuffer): string {
    const hexDigest = SparkMD5.ArrayBuffer.hash(arrayBuffer);
    return hexToBase64(hexDigest);
}

/**
 * Upload file to Cloudinary via Rails Active Storage
 * @param {File} file - The file to upload
 * @param {any} apolloClient - Apollo client instance
 * @returns {Promise<string>} Signed ID for attaching to models
 */
export async function uploadToCloudinary(file: File, apolloClient: any): Promise<string> {
    try {
        // 1. Read file and calculate checksum
        const arrayBuffer = await file.arrayBuffer();
        const checksum = calculateChecksum(arrayBuffer);

        // 2. Request direct upload URL from Rails
        const { data } = await apolloClient.mutate({
            mutation: CREATE_DIRECT_UPLOAD_MUTATION,
            variables: {
                filename: file.name,
                byteSize: file.size,
                checksum: checksum,
                contentType: file.type,
            },
        });

        const payload = data?.createDirectUpload;
        if (!payload) {
            throw new Error('Direct upload payload missing');
        }

        if (Array.isArray(payload.errors) && payload.errors.length > 0) {
            throw new Error(payload.errors.join(', '));
        }

        const { url, headers, signedId } = payload.directUpload;

        if (!url || !headers || !signedId) {
            throw new Error('Direct upload response incomplete');
        }

        // 3. Upload file to Cloudinary
        const uploadHeaders = new Headers();
        const headersObj = typeof headers === 'string' ? JSON.parse(headers) : headers;

        Object.entries(headersObj).forEach(([key, value]) => {
            if (Array.isArray(value)) {
                value.forEach((val) => uploadHeaders.append(key, String(val)));
            } else if (value != null) {
                uploadHeaders.append(key, String(value));
            }
        });

        const uploadResponse = await fetch(url, {
            method: 'PUT',
            headers: uploadHeaders,
            body: file,
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
