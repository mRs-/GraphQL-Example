import Foundation
import LoggerAPI
import Kitura
import KituraContracts

protocol HasProductStore {
    var productStore: [UUID: Product] { get }
}

protocol HasRouter {
    var router: Router { get }
}

class ProductRouter {
    
    struct Dependencies: HasProductStore, HasRouter {
        var productStore: [UUID: Product]
        var router: Router
    }
    
    private var container: Dependencies!
    
    func initializeProductRoutes(withDependencies container: Dependencies) {
        self.container = container
        
        // Product
        container.router.post("/product", handler: storeProductHandler)
        container.router.get("/product", handler: loadProductHandler)
        
        // Product Fav
        container.router.post("/productFav", handler: storeFavProduct)
        container.router.delete("/productFav", handler: deleteFavProduct)
        
        // Product List
        container.router.get("/products", handler: loadProductsHandler)
    }
    
    private func deleteFavProduct(id: String, completion: (RequestError?) -> Void) {
        guard let uuid = UUID(uuidString: id) else {
            completion(.badRequest)
            return
        }
        
        guard var product = container.productStore[uuid] else {
            completion(.notFound)
            return
        }
        
        product.favorised = false
        container.productStore[product.id] = product
        
        completion(nil)
    }
    
    private func storeFavProduct(id: String, completion: (String, RequestError?) -> Void ) {
        guard let uuid = UUID(uuidString: id) else {
            completion("", .badRequest)
            return
        }
        
        guard var product = container.productStore[uuid] else {
            completion("", .notFound)
            return
        }
        
        product.favorised = true
        container.productStore[product.id] = product
        
        completion("", nil)
    }
    
    private func storeProductHandler(product: Product, completion: (Product?, RequestError?) -> Void )  {
        container.productStore[product.id] = product
        completion(container.productStore[product.id], nil)
    }
    
    func loadProductHandler(id: String, completion: (Product?, RequestError?) -> Void) {
        guard let uuid = UUID(uuidString: id) else {
            completion(nil, .badRequest)
            return
        }
        
        guard let product = container.productStore[uuid] else {
            completion(nil, .notFound)
            return
        }
        completion(product, nil)
    }
    
    func loadProductsHandler(completion:(Products?, RequestError?) -> Void) {
        completion(container.productStore.map { $0.value }, nil)
    }
}
