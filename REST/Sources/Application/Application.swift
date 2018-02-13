import Foundation
import Kitura
import LoggerAPI
import Configuration
import CloudEnvironment
import KituraContracts
import Health

public let projectPath = ConfigurationManager.BasePath.project.path
public let health = Health()
private var productStore: [UUID: Product] = [:]
private var categoryStore: [UUID: Category] = [:]
private var productRouter = ProductRouter()

public class App {
    let router = Router()
    let cloudEnv = CloudEnv()

    public init() throws {
    }
    
    func postInit() throws {
        // Capabilities
        initializeMetrics(app: self)

        // Endpoints
        initializeHealthRoutes(app: self)
        
        generateMockData()
        
        // Setup Dependencies
        let productRouterDependencies = ProductRouter.Dependencies(productStore: productStore,
                                                                   router: router)
        
        // Initalize Product Routes
        productRouter.initializeProductRoutes(withDependencies: productRouterDependencies)
        
    }

    public func run() throws {
        try postInit()
        Kitura.addHTTPServer(onPort: cloudEnv.port, with: router)
        Kitura.run()
    }
    
    private func generateMockData() {
        // Setup Category Data
        let actionFiguresCategory = Category(name: "Action Figures")
        let starWarsCategory = Category(name: "Star Wars")
        let ninjaTurtlesCategory = Category(name: "Ninja Turtles")
        let fryingPansCategory = Category(name: "Frying Pans")
        
        // Setup Test Data
        let dearthmaul = Product(name: "Darth Maul Action Figure",
                                 categories: [starWarsCategory, actionFiguresCategory],
                                 description: "Cillum nostrud kielbasa, ut leberkas pastrami biltong pork bresaola ullamco est cow porchetta kevin sirloin. Nulla chicken magna irure fatback, mollit short ribs. Id mollit meatball aliquip irure jowl officia shankle fatback. Occaecat adipisicing dolore enim short loin quis. Jerky ut beef, ham occaecat corned beef short loin prosciutto irure ham hock consectetur aute veniam porchetta.",
                                 recommendations: [],
                                 favorised: false)
        
        let jarjar = Product(name: "Jar Jar Bings Action Figure",
                             categories: [starWarsCategory, actionFiguresCategory],
                             description: "Landjaeger ipsum strip steak frankfurter id pariatur. Turkey t-bone ham, cupidatat voluptate fugiat do rump sint meatball jerky pork pancetta chicken shoulder. Aliquip t-bone in dolor rump sirloin. Burgdoggen doner ball tip eu turkey nostrud, ad fatback elit reprehenderit bacon id. Pork chop andouille tail meatball voluptate. Fatback ball tip jerky cillum in, sed dolore consectetur aliquip minim cupidatat beef ribs officia nisi pork.",
                             recommendations: [],
                             favorised: false)
        
        let michelangelo = Product(name: "Michelangelo Action Figure",
                                   categories: [ninjaTurtlesCategory, actionFiguresCategory],
                                   description: "T-bone nisi pancetta, fatback tri-tip sint ut. Voluptate ut ham in. Labore qui dolore ipsum aliquip beef, ea brisket consequat short ribs. In sausage t-bone non capicola turducken pastrami buffalo laborum doner cupim est ham pancetta. Picanha sint irure, tri-tip tenderloin ball tip frankfurter qui nostrud prosciutto aliqua chuck brisket boudin. Sirloin minim spare ribs, tail reprehenderit lorem cupidatat sint cupim shoulder.",
                                   recommendations: [],
                                   favorised: true)
        
        var jamieOliverFryingPan = Product(name: "Jamie Oliver Frying Pan",
                                           categories: [fryingPansCategory],
                                           description: "Tri-tip turkey cupim ball tip, reprehenderit leberkas short loin veniam shankle dolor shoulder sint. Aliqua tri-tip velit, chicken corned beef mollit ex venison filet mignon beef picanha drumstick alcatra ipsum. Consectetur in sausage ullamco. Andouille tenderloin laboris cillum, aliquip tongue irure dolor.",
                                           recommendations: [],
                                           favorised: true)
        
        jamieOliverFryingPan.recommendations.append(jarjar.id)
        jamieOliverFryingPan.recommendations.append(michelangelo.id)
        
        
        productStore[dearthmaul.id] = dearthmaul
        productStore[jarjar.id] = jarjar
        productStore[michelangelo.id] = michelangelo
        productStore[jamieOliverFryingPan.id] = jamieOliverFryingPan
    }
}
