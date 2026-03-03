import '../../domain/entities/menu_item.dart';
import '../../domain/entities/restaurant.dart';

class FoodDeliveryLocalDatasource {
  static const _delay = Duration(milliseconds: 300);

  // TheMealDB image base
  static const _m = 'https://www.themealdb.com/images/media/meals';

  // Foodish image base
  static const _f = 'https://foodish-api.com/images';

  // Picsum fallback (seed-based, consistent)
  static const _p = 'https://picsum.photos/seed';

  final List<Restaurant> _restaurants = const [
    Restaurant(
      id: 'r1',
      name: 'Pizza Palace',
      imageUrl: '$_f/pizza/pizza51.jpg',
      rating: 4.8,
      cuisineType: 'Italian',
      deliveryTimeMinutes: 30,
      deliveryFee: 2.99,
    ),
    Restaurant(
      id: 'r2',
      name: 'Dragon Wok',
      imageUrl: '$_m/1529444113.jpg',
      rating: 4.6,
      cuisineType: 'Chinese',
      deliveryTimeMinutes: 25,
      deliveryFee: 1.99,
    ),
    Restaurant(
      id: 'r3',
      name: 'Taco Heaven',
      imageUrl: '$_m/ypxvwv1505333929.jpg',
      rating: 4.7,
      cuisineType: 'Mexican',
      deliveryTimeMinutes: 20,
      deliveryFee: 2.49,
    ),
    Restaurant(
      id: 'r4',
      name: 'Sushi Master',
      imageUrl: '$_m/g046bb1663960946.jpg',
      rating: 4.9,
      cuisineType: 'Japanese',
      deliveryTimeMinutes: 35,
      deliveryFee: 3.49,
    ),
    Restaurant(
      id: 'r5',
      name: 'Burger Joint',
      imageUrl: '$_f/burger/burger50.jpg',
      rating: 4.5,
      cuisineType: 'American',
      deliveryTimeMinutes: 20,
      deliveryFee: 1.49,
    ),
    Restaurant(
      id: 'r6',
      name: 'Spice Route',
      imageUrl: '$_f/biryani/biryani30.jpg',
      rating: 4.7,
      cuisineType: 'Indian',
      deliveryTimeMinutes: 30,
      deliveryFee: 2.99,
    ),
  ];

  final Map<String, List<MenuItem>> _menuItems = const {
    // ── Pizza Palace (Italian) ──
    'r1': [
      // Mains
      MenuItem(id: 'm1', name: 'Margherita Pizza', imageUrl: '$_f/pizza/pizza1.jpg', price: 12.99, description: 'Classic tomato sauce, fresh mozzarella, and basil on a crispy thin crust.', restaurantId: 'r1', category: 'Mains'),
      MenuItem(id: 'm2', name: 'Pepperoni Pizza', imageUrl: '$_f/pizza/pizza20.jpg', price: 14.99, description: 'Loaded with spicy pepperoni and melted mozzarella cheese.', restaurantId: 'r1', category: 'Mains'),
      MenuItem(id: 'm3', name: 'Pasta Carbonara', imageUrl: '$_f/pasta/pasta10.jpg', price: 15.99, description: 'Creamy egg-based sauce with pancetta, parmesan, and black pepper.', restaurantId: 'r1', category: 'Mains'),
      MenuItem(id: 'm4', name: 'Four Cheese Pizza', imageUrl: '$_f/pizza/pizza35.jpg', price: 16.49, description: 'Mozzarella, gorgonzola, parmesan, and fontina on a wood-fired crust.', restaurantId: 'r1', category: 'Mains'),
      MenuItem(id: 'm5', name: 'Penne Arrabbiata', imageUrl: '$_f/pasta/pasta5.jpg', price: 13.49, description: 'Penne in a spicy tomato sauce with garlic and red chili flakes.', restaurantId: 'r1', category: 'Mains'),
      // Sides
      MenuItem(id: 'm6', name: 'Garlic Bread', imageUrl: '$_p/garlic-bread/400/300', price: 8.49, description: 'Toasted ciabatta with garlic butter and herbs.', restaurantId: 'r1', category: 'Sides'),
      MenuItem(id: 'm7', name: 'Bruschetta', imageUrl: '$_p/bruschetta/400/300', price: 9.49, description: 'Grilled bread topped with diced tomatoes, basil, and olive oil.', restaurantId: 'r1', category: 'Sides'),
      MenuItem(id: 'm8', name: 'Caesar Salad', imageUrl: '$_p/caesar-salad/400/300', price: 10.49, description: 'Crisp romaine, parmesan, croutons, and creamy Caesar dressing.', restaurantId: 'r1', category: 'Sides'),
      // Drinks
      MenuItem(id: 'm9', name: 'Tiramisu', imageUrl: '$_f/dessert/dessert10.jpg', price: 9.99, description: 'Espresso-soaked ladyfingers layered with mascarpone cream.', restaurantId: 'r1', category: 'Drinks'),
      MenuItem(id: 'm10', name: 'Italian Soda', imageUrl: '$_p/italian-soda/400/300', price: 5.49, description: 'Sparkling water with your choice of fruit syrup and cream.', restaurantId: 'r1', category: 'Drinks'),
      MenuItem(id: 'm11', name: 'Espresso', imageUrl: '$_p/espresso/400/300', price: 4.49, description: 'Rich double-shot espresso made with premium Italian beans.', restaurantId: 'r1', category: 'Drinks'),
    ],

    // ── Dragon Wok (Chinese) ──
    'r2': [
      // Mains
      MenuItem(id: 'm12', name: 'Kung Pao Chicken', imageUrl: '$_m/1525872624.jpg', price: 13.99, description: 'Spicy stir-fried chicken with peanuts, chili, and Sichuan peppercorns.', restaurantId: 'r2', category: 'Mains'),
      MenuItem(id: 'm13', name: 'Sweet & Sour Pork', imageUrl: '$_m/1529442316.jpg', price: 14.49, description: 'Crispy battered pork tossed in tangy sweet and sour sauce.', restaurantId: 'r2', category: 'Mains'),
      MenuItem(id: 'm14', name: 'Fried Rice', imageUrl: '$_m/wuyd2h1765655837.jpg', price: 10.99, description: 'Wok-tossed rice with egg, vegetables, and soy sauce.', restaurantId: 'r2', category: 'Mains'),
      MenuItem(id: 'm15', name: 'Beef Chow Mein', imageUrl: '$_m/1529444830.jpg', price: 14.99, description: 'Stir-fried egg noodles with tender beef and mixed vegetables.', restaurantId: 'r2', category: 'Mains'),
      MenuItem(id: 'm16', name: 'Mapo Tofu', imageUrl: '$_m/1525874812.jpg', price: 12.49, description: 'Silky tofu in a fiery Sichuan chili bean sauce with ground pork.', restaurantId: 'r2', category: 'Mains'),
      // Sides
      MenuItem(id: 'm17', name: 'Spring Rolls', imageUrl: '$_m/grhn401765687086.jpg', price: 8.99, description: 'Crispy vegetable spring rolls with sweet chili dipping sauce.', restaurantId: 'r2', category: 'Sides'),
      MenuItem(id: 'm18', name: 'Wonton Soup', imageUrl: '$_m/1525876468.jpg', price: 9.49, description: 'Delicate pork wontons in a clear aromatic broth.', restaurantId: 'r2', category: 'Sides'),
      MenuItem(id: 'm19', name: 'Steamed Dumplings', imageUrl: '$_m/sfahy01763752319.jpg', price: 10.49, description: 'Juicy pork and ginger dumplings with soy dipping sauce.', restaurantId: 'r2', category: 'Sides'),
      // Drinks
      MenuItem(id: 'm20', name: 'Jasmine Tea', imageUrl: '$_p/jasmine-tea/400/300', price: 4.49, description: 'Fragrant hot jasmine green tea, served in a traditional pot.', restaurantId: 'r2', category: 'Drinks'),
      MenuItem(id: 'm21', name: 'Lychee Juice', imageUrl: '$_p/lychee-juice/400/300', price: 5.99, description: 'Refreshing chilled lychee juice with a hint of lime.', restaurantId: 'r2', category: 'Drinks'),
    ],

    // ── Taco Heaven (Mexican) ──
    'r3': [
      // Mains
      MenuItem(id: 'm22', name: 'Carne Asada Tacos', imageUrl: '$_m/uvuyxu1503067369.jpg', price: 13.49, description: 'Grilled steak tacos with fresh cilantro, onion, and lime.', restaurantId: 'r3', category: 'Mains'),
      MenuItem(id: 'm23', name: 'Chicken Burrito', imageUrl: '$_m/tvtxpq1511464705.jpg', price: 12.99, description: 'Flour tortilla stuffed with seasoned chicken, rice, beans, and cheese.', restaurantId: 'r3', category: 'Mains'),
      MenuItem(id: 'm24', name: 'Quesadilla', imageUrl: '$_p/quesadilla/400/300', price: 10.99, description: 'Grilled flour tortilla with melted cheese, peppers, and sour cream.', restaurantId: 'r3', category: 'Mains'),
      MenuItem(id: 'm25', name: 'Enchiladas', imageUrl: '$_m/qtuwxu1468233098.jpg', price: 14.49, description: 'Corn tortillas filled with chicken, smothered in red chili sauce and cheese.', restaurantId: 'r3', category: 'Mains'),
      // Sides
      MenuItem(id: 'm26', name: 'Guacamole & Chips', imageUrl: '$_p/guacamole/400/300', price: 8.99, description: 'Fresh avocado dip with tomato, onion, lime, and crispy tortilla chips.', restaurantId: 'r3', category: 'Sides'),
      MenuItem(id: 'm27', name: 'Elote', imageUrl: '$_p/elote/400/300', price: 6.99, description: 'Grilled Mexican street corn with mayo, cotija cheese, and chili powder.', restaurantId: 'r3', category: 'Sides'),
      MenuItem(id: 'm28', name: 'Churros', imageUrl: '$_f/dessert/dessert20.jpg', price: 7.99, description: 'Crispy cinnamon sugar pastries with chocolate dipping sauce.', restaurantId: 'r3', category: 'Sides'),
      // Drinks
      MenuItem(id: 'm29', name: 'Horchata', imageUrl: '$_p/horchata/400/300', price: 5.49, description: 'Creamy rice-based drink with cinnamon and vanilla.', restaurantId: 'r3', category: 'Drinks'),
      MenuItem(id: 'm30', name: 'Agua Fresca', imageUrl: '$_p/agua-fresca/400/300', price: 4.99, description: 'Light watermelon and lime refresher with a hint of mint.', restaurantId: 'r3', category: 'Drinks'),
    ],

    // ── Sushi Master (Japanese) ──
    'r4': [
      // Mains
      MenuItem(id: 'm31', name: 'Salmon Sashimi', imageUrl: '$_m/g046bb1663960946.jpg', price: 18.99, description: 'Fresh slices of premium Atlantic salmon, served with wasabi.', restaurantId: 'r4', category: 'Mains'),
      MenuItem(id: 'm32', name: 'Dragon Roll', imageUrl: '$_p/dragon-roll/400/300', price: 16.99, description: 'Shrimp tempura roll topped with avocado and eel sauce.', restaurantId: 'r4', category: 'Mains'),
      MenuItem(id: 'm33', name: 'Chicken Teriyaki', imageUrl: '$_m/wvpsxx1468256321.jpg', price: 14.99, description: 'Grilled chicken glazed with sweet teriyaki sauce, served with rice.', restaurantId: 'r4', category: 'Mains'),
      MenuItem(id: 'm34', name: 'Tonkotsu Ramen', imageUrl: '$_m/ip5xtp1769779958.jpg', price: 15.99, description: 'Rich pork bone broth with chashu, soft egg, nori, and fresh noodles.', restaurantId: 'r4', category: 'Mains'),
      MenuItem(id: 'm35', name: 'Spicy Tuna Roll', imageUrl: '$_p/spicy-tuna-roll/400/300', price: 14.49, description: 'Fresh tuna with spicy mayo, cucumber, and sesame seeds.', restaurantId: 'r4', category: 'Mains'),
      // Sides
      MenuItem(id: 'm36', name: 'Miso Soup', imageUrl: '$_p/miso-soup/400/300', price: 8.49, description: 'Traditional soybean paste soup with tofu, seaweed, and scallions.', restaurantId: 'r4', category: 'Sides'),
      MenuItem(id: 'm37', name: 'Edamame', imageUrl: '$_p/edamame/400/300', price: 6.99, description: 'Steamed young soybeans lightly salted, a classic Japanese appetizer.', restaurantId: 'r4', category: 'Sides'),
      MenuItem(id: 'm38', name: 'Gyoza', imageUrl: '$_m/wrustq1511475474.jpg', price: 9.49, description: 'Pan-fried pork dumplings with a crispy bottom and soy dipping sauce.', restaurantId: 'r4', category: 'Sides'),
      // Drinks
      MenuItem(id: 'm39', name: 'Matcha Latte', imageUrl: '$_p/matcha-latte/400/300', price: 6.49, description: 'Creamy ceremonial-grade matcha whisked with steamed milk.', restaurantId: 'r4', category: 'Drinks'),
      MenuItem(id: 'm40', name: 'Calpis Soda', imageUrl: '$_p/calpis-soda/400/300', price: 4.99, description: 'Refreshing Japanese yogurt-flavoured carbonated drink.', restaurantId: 'r4', category: 'Drinks'),
    ],

    // ── Burger Joint (American) ──
    'r5': [
      // Mains
      MenuItem(id: 'm41', name: 'Classic Cheeseburger', imageUrl: '$_f/burger/burger1.jpg', price: 11.99, description: 'Juicy beef patty with cheddar, lettuce, tomato, and pickles.', restaurantId: 'r5', category: 'Mains'),
      MenuItem(id: 'm42', name: 'BBQ Bacon Burger', imageUrl: '$_f/burger/burger20.jpg', price: 14.99, description: 'Smoky BBQ sauce, crispy bacon, and cheddar on a toasted bun.', restaurantId: 'r5', category: 'Mains'),
      MenuItem(id: 'm43', name: 'Chicken Wings', imageUrl: '$_m/4hzyvq1763792564.jpg', price: 12.49, description: 'Crispy buffalo wings served with ranch dipping sauce.', restaurantId: 'r5', category: 'Mains'),
      MenuItem(id: 'm44', name: 'Mushroom Swiss Burger', imageUrl: '$_f/burger/burger35.jpg', price: 13.99, description: 'Sauteed mushrooms and melted Swiss cheese on a chargrilled patty.', restaurantId: 'r5', category: 'Mains'),
      // Sides
      MenuItem(id: 'm45', name: 'Loaded Fries', imageUrl: '$_p/loaded-fries/400/300', price: 9.49, description: 'Crispy fries topped with cheese sauce, bacon bits, and jalapeños.', restaurantId: 'r5', category: 'Sides'),
      MenuItem(id: 'm46', name: 'Onion Rings', imageUrl: '$_p/onion-rings/400/300', price: 7.99, description: 'Beer-battered onion rings fried golden, served with ketchup.', restaurantId: 'r5', category: 'Sides'),
      MenuItem(id: 'm47', name: 'Coleslaw', imageUrl: '$_p/coleslaw/400/300', price: 5.49, description: 'Creamy cabbage and carrot slaw with a tangy dressing.', restaurantId: 'r5', category: 'Sides'),
      // Drinks
      MenuItem(id: 'm48', name: 'Milkshake', imageUrl: '$_p/milkshake/400/300', price: 8.49, description: 'Thick and creamy vanilla milkshake with whipped cream.', restaurantId: 'r5', category: 'Drinks'),
      MenuItem(id: 'm49', name: 'Root Beer Float', imageUrl: '$_p/root-beer-float/400/300', price: 6.99, description: 'Classic root beer with a scoop of vanilla ice cream.', restaurantId: 'r5', category: 'Drinks'),
      MenuItem(id: 'm50', name: 'Lemonade', imageUrl: '$_p/lemonade/400/300', price: 4.49, description: 'Freshly squeezed lemonade with a hint of mint.', restaurantId: 'r5', category: 'Drinks'),
    ],

    // ── Spice Route (Indian) ──
    'r6': [
      // Mains
      MenuItem(id: 'm51', name: 'Butter Chicken', imageUrl: '$_f/butter-chicken/butter-chicken10.jpg', price: 15.99, description: 'Tender chicken in rich, creamy tomato-based curry with aromatic spices.', restaurantId: 'r6', category: 'Mains'),
      MenuItem(id: 'm52', name: 'Lamb Biryani', imageUrl: '$_m/xrttsx1487339558.jpg', price: 17.99, description: 'Fragrant basmati rice layered with spiced lamb and caramelised onions.', restaurantId: 'r6', category: 'Mains'),
      MenuItem(id: 'm53', name: 'Palak Paneer', imageUrl: '$_m/xxpqsy1511452222.jpg', price: 13.99, description: 'Creamy spinach curry with cubes of soft Indian cottage cheese.', restaurantId: 'r6', category: 'Mains'),
      MenuItem(id: 'm54', name: 'Chicken Tikka Masala', imageUrl: '$_m/qptpvt1487339892.jpg', price: 16.49, description: 'Chargrilled chicken chunks in a velvety spiced tomato and cream sauce.', restaurantId: 'r6', category: 'Mains'),
      // Sides
      MenuItem(id: 'm55', name: 'Garlic Naan', imageUrl: '$_p/garlic-naan/400/300', price: 4.49, description: 'Soft tandoori bread brushed with garlic butter.', restaurantId: 'r6', category: 'Sides'),
      MenuItem(id: 'm56', name: 'Samosa', imageUrl: '$_f/samosa/samosa10.jpg', price: 7.99, description: 'Crispy pastry filled with spiced potatoes and peas.', restaurantId: 'r6', category: 'Sides'),
      MenuItem(id: 'm57', name: 'Raita', imageUrl: '$_p/raita/400/300', price: 3.99, description: 'Cool yogurt dip with cucumber, mint, and cumin.', restaurantId: 'r6', category: 'Sides'),
      // Drinks
      MenuItem(id: 'm58', name: 'Mango Lassi', imageUrl: '$_p/mango-lassi/400/300', price: 5.99, description: 'Refreshing yogurt-based drink blended with sweet mango.', restaurantId: 'r6', category: 'Drinks'),
      MenuItem(id: 'm59', name: 'Masala Chai', imageUrl: '$_p/masala-chai/400/300', price: 4.49, description: 'Spiced Indian tea brewed with cardamom, ginger, and cinnamon.', restaurantId: 'r6', category: 'Drinks'),
      MenuItem(id: 'm60', name: 'Rose Lemonade', imageUrl: '$_p/rose-lemonade/400/300', price: 5.49, description: 'Sparkling lemonade infused with fragrant rose water.', restaurantId: 'r6', category: 'Drinks'),
    ],
  };

  Future<List<Restaurant>> getRestaurants() async {
    await Future.delayed(_delay);
    return _restaurants;
  }

  Future<List<MenuItem>> getMenuItems(String restaurantId) async {
    await Future.delayed(_delay);
    return _menuItems[restaurantId] ?? [];
  }
}
