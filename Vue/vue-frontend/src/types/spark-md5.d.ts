declare module 'spark-md5' {
    interface SparkMd5Class {
        reset(): void
        append(str: string | ArrayBuffer): SparkMd5Class
        appendBinary(str: string): SparkMd5Class
        end(raw?: boolean): string
    }

    interface SparkMd5Static {
        new(): SparkMd5Class
        hash(str: string, raw?: boolean): string
        hashBinary(str: string, raw?: boolean): string
        ArrayBuffer: {
            hash(array: ArrayBuffer, raw?: boolean): string
        }
    }

    const SparkMD5: SparkMd5Static
    export default SparkMD5
}
