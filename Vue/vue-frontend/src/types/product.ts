export interface ProductUser {
    id: number
    firstName: string | null
    lastName: string | null
    email: string
}

export interface ProductItem {
    id: number
    name: string
    description: string
    price: number
    category: string
    productType: string
    image?: string | null
    quantity?: number
    user?: ProductUser | null
}
