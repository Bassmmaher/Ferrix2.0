import '../entities/product.dart';
import '../value_objects/product_id.dart';

/// Contract for persisting and retrieving [Product] aggregates.
///
/// Implementations live in the infrastructure layer
/// (e.g. `InMemoryProductRepository`, `PostgresProductRepository`).
/// The application layer depends only on this interface — never on a
/// concrete implementation.
abstract class ProductRepository {
  /// Find a single product by its identity.
  ///
  /// Returns `null` if no product exists with this id.
  Future<Product?> findById(ProductId id);

  /// Paginated list of products, newest first.
  ///
  /// [limit]  — max number of items to return (defaults to 20).
  /// [offset] — number of items to skip (defaults to 0).
  Future<List<Product>> findAll({
    int limit = 20,
    int offset = 0,
  });

  /// Insert a brand new product.
  ///
  /// Must throw [ProductAlreadyExistsError] if the id is already taken.
  Future<void> save(Product product);

  /// Persist changes to an existing product.
  ///
  /// Must throw [ProductNotFoundError] if the product doesn't exist.
  Future<void> update(Product product);

  /// Remove a product.
  ///
  /// Idempotent: succeeds silently if the product doesn't exist.
  Future<void> delete(ProductId id);

  /// Total number of products in the store.
  /// Useful for pagination metadata on list endpoints.
  Future<int> count();

  /// Case-insensitive partial-match search on the product name.
  ///
  /// If [query] is empty or whitespace, behaves like [findAll].
  Future<List<Product>> searchByName(
    String query, {
    int limit = 20,
    int offset = 0,
  });
} (product_repository.dart)