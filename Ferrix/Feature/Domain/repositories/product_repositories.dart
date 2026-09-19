// lib/features/product/domain/repositories/product_repository.dart

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/product.dart';

abstract class ProductRepository {
  /// Fetches all products.
  ///
  /// Returns a [List<Product>] on success, or a [Failure] on error.
  Future<Either<Failure, List<Product>>> getProducts();

  /// Fetches a single product by its [id].
  Future<Either<Failure, Product>> getProductById(String id);

  /// Creates a new product.
  Future<Either<Failure, Product>> createProduct(Product product);

  /// Updates an existing product.
  Future<Either<Failure, Product>> updateProduct(Product product);

  /// Deletes a product by its [id].
  Future<Either<Failure, void>> deleteProduct(String id);

  /// Searches products by a query string.
  Future<Either<Failure, List<Product>>> searchProducts(String query);

  /// Fetches products filtered by [category].
  Future<Either<Failure, List<Product>>> getProductsByCategory(
    String category,
  );
}