const express = require('express');
const bodyParser = require('body-parser');
const { graphqlExpress, graphiqlExpress } = require('apollo-server-express');
const { makeExecutableSchema } = require('graphql-tools');
const fetch = require('node-fetch');
const rp = require('request-promise');

const kituraServerURL = 'http://localhost:8080/';

// The GraphQL schema in string form
const typeDefs = `

  type Product {
    id: String!
    name: String!
    #deprecated use description2
    description: String
    description2: Description
    favorised: Boolean!
    recommendations: [Product]
    categories: [Category]
  }

  type Category {
      id: String!
      name: String!
  }

  type Query {
    products: [Product]
    product(id: String!): Product
  }

  type Mutation {
    fav(productID: String!): Product
    unfav(productID: String!): Product
  }
`;

// The resolvers
const resolvers = {
  Query: { 
      products: () => getProducts(),
      product: (root, { id }) => getProduct(id)
  },
  Mutation: {
      fav: (root, { productID }) => favProduct(productID),
      unfav: (root, { productID }) => unFavProduct(productID)
  }
};

function favProduct(productID) {
    var options = {
        method: 'POST',
        uri: kituraServerURL + 'productFav/' + productID,
        body: {},
        json: true 
    };
    return rp(options)
        .then(res => {
            console.log(res);
        })
        .catch(error => {
            console.log(error)
        })
        .then(res => getProduct(productID))
}

function unFavProduct(productID) {
    var options = {
        method: 'DELETE',
        uri: kituraServerURL + 'productFav/' + productID,
        body: {},
        json: true 
    };
    return rp(options)
        .then(res => {
            console.log(res);
        })
        .catch(error => {
            console.log(error)
        })
        .then(res => getProduct(productID))
}

function getProducts() {
    return fetch(kituraServerURL + 'products')
        .then(res => res.json())
        .then(res => {
            res.forEach(product => {
                if (product.recommendations != null) {
                    var recommendations = new Array();
                    product.recommendations.forEach(productID => {
                        recommendations[recommendations.length] = getProduct(productID);
                    });
                    product.recommendations = recommendations;
                }
            });
            return res;
        });
}

function getProduct(id) {
    return fetch(kituraServerURL + 'product/' + id)
    .then(res => res.json())
    .then(res => {
        return res;
    });
}

// Put together a schema
const schema = makeExecutableSchema({
  typeDefs,
  resolvers,
});

// Initialize the app
const app = express();

// The GraphQL endpoint
app.use('/graphql', bodyParser.json(), graphqlExpress({ schema }));

// GraphiQL, a visual editor for queries
app.use('/graphiql', graphiqlExpress({ endpointURL: '/graphql' }));

// Start the server
app.listen(3000, () => {
  console.log('Go to http://localhost:3000/graphiql to run queries!');
});