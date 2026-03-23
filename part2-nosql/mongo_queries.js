// ============================================================
// Part 2.2 — MongoDB Operations
// ============================================================

// Connect to the database (run in mongosh)
// use ecommerce_db

// ------------------------------------------------------------
// OP1: insertMany() — insert all 3 documents from sample_documents.json
// ------------------------------------------------------------
db.products.insertMany([
  {
    _id: "prod_elec_001",
    name: "Samsung 4K Smart TV",
    category: "Electronics",
    brand: "Samsung",
    price: 45999,
    stock: 30,
    specs: {
      screen_size_inches: 55,
      resolution: "3840x2160",
      voltage: "220V",
      warranty_years: 2,
      smart_features: ["Netflix", "YouTube", "Alexa Built-in"],
      connectivity: ["HDMI", "USB", "Wi-Fi", "Bluetooth"]
    },
    ratings: {
      average: 4.3,
      total_reviews: 512
    },
    tags: ["television", "4K", "smart TV", "Samsung"],
    added_on: "2024-01-15"
  },
  {
    _id: "prod_cloth_001",
    name: "Men's Slim Fit Formal Shirt",
    category: "Clothing",
    brand: "Arrow",
    price: 1299,
    stock: 150,
    specs: {
      fabric: "100% Cotton",
      fit: "Slim Fit",
      collar: "Spread Collar",
      sleeve: "Full Sleeve",
      care_instructions: ["Machine wash cold", "Do not bleach", "Iron on medium heat"],
      available_sizes: ["S", "M", "L", "XL", "XXL"],
      available_colors: ["White", "Light Blue", "Grey", "Navy"]
    },
    ratings: {
      average: 4.1,
      total_reviews: 238
    },
    tags: ["shirt", "formal", "men", "cotton"],
    added_on: "2024-03-10"
  },
  {
    _id: "prod_groc_001",
    name: "Organic Whole Wheat Flour",
    category: "Groceries",
    brand: "Aashirvaad",
    price: 320,
    stock: 500,
    specs: {
      weight_kg: 5,
      ingredients: ["100% Whole Wheat"],
      nutritional_info: {
        per_100g: {
          calories_kcal: 341,
          protein_g: 12.5,
          carbohydrates_g: 69.2,
          fat_g: 1.9,
          fiber_g: 10.7
        }
      },
      certifications: ["FSSAI Certified", "Organic India"],
      allergens: ["Gluten"],
      storage: "Store in a cool, dry place",
      expiry_date: "2025-06-30",
      manufactured_date: "2024-11-01"
    },
    ratings: {
      average: 4.6,
      total_reviews: 1024
    },
    tags: ["flour", "organic", "wheat", "grocery", "staple"],
    added_on: "2024-11-05"
  }
]);

// ------------------------------------------------------------
// OP2: find() — retrieve all Electronics products with price > 20000
// ------------------------------------------------------------
db.products.find(
  {
    category: "Electronics",
    price: { $gt: 20000 }
  },
  {
    name: 1,
    brand: 1,
    price: 1,
    category: 1,
    _id: 0
  }
);

// ------------------------------------------------------------
// OP3: find() — retrieve all Groceries expiring before 2025-01-01
// ------------------------------------------------------------
db.products.find(
  {
    category: "Groceries",
    "specs.expiry_date": { $lt: "2025-01-01" }
  },
  {
    name: 1,
    brand: 1,
    "specs.expiry_date": 1,
    _id: 0
  }
);

// ------------------------------------------------------------
// OP4: updateOne() — add a "discount_percent" field to a specific product
// ------------------------------------------------------------
db.products.updateOne(
  { _id: "prod_elec_001" },             // Filter: target the Samsung TV
  {
    $set: {
      discount_percent: 10,             // Add new field: 10% discount
      discounted_price: 41399.10        // Add computed discounted price
    }
  }
);
// Explanation:
// - $set operator adds or updates fields without affecting the rest of the document
// - Only the document with _id "prod_elec_001" is modified
// - If "discount_percent" already exists, $set will update its value

// ------------------------------------------------------------
// OP5: createIndex() — create an index on category field and explain why
// ------------------------------------------------------------
db.products.createIndex(
  { category: 1 },                      // 1 = ascending index on "category"
  { name: "idx_category" }              // optional: give the index a readable name
);
