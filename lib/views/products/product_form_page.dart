import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../controllers/product_controller.dart';
import '../../data/models/product_model.dart';
import '../../data/models/attribute_model.dart';

class ProductFormPage extends StatefulWidget {
  final ProductModel? product; // thêm dòng này
  const ProductFormPage({
    super.key,
    this.product, // thêm dòng này
  });
  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> imageControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final titleController = TextEditingController();
  final skuController = TextEditingController();
  final priceController = TextEditingController();
  final saleController = TextEditingController();
  final stockController = TextEditingController();
  final thumbnailController = TextEditingController();
  final descriptionController = TextEditingController();
  final discountController = TextEditingController();
  final tagController = TextEditingController();
  late QuillController _quillController;
  ProductType productType = ProductType.simple;
  bool isDraft = false;
  String? selectedBrandId;
  List<String> selectedCategoryIds = [];
  List<Map<String, dynamic>> selectedAttributes = [];
  AttributeModel? currentAttribute;
  List<String> additionalImages = [];
  List<String> tempSelectedValues = [];
  @override
  void initState() {
    super.initState();
    final controller = context.read<ProductController>();
    controller.loadInitialData();
    _quillController = QuillController.basic();
    if (widget.product != null) {
      final p = widget.product!;
      titleController.text = p.title;
      skuController.text = p.sku ?? "";
      priceController.text = p.price.toString();
      saleController.text = p.salePrice?.toString() ?? "";
      stockController.text = p.stock.toString();
      thumbnailController.text = p.thumbnail;
      productType = p.productType;
      isDraft = p.isDraft;
      selectedBrandId = p.brandId;
      selectedCategoryIds = p.categoryIds ?? [];
      selectedAttributes = (p.attributes ?? [])
          .map(
            (attr) => {
              "attributeId": attr["attributeId"]?.toString() ?? "",
              "name": attr["name"]?.toString() ?? "",
              "values": _asStringList(attr["values"]),
            },
          )
          .where((attr) => (attr["attributeId"] as String).isNotEmpty)
          .toList();

      /// images
      final imgs = p.images ?? [];
      for (int i = 0; i < imgs.length && i < imageControllers.length; i++) {
        imageControllers[i].text = imgs[i];
      }

      /// tags
      tagController.text = (p.tags ?? []).join(',');

      /// description (QUILL)
      try {
        if (p.description.isNotEmpty) {
          _quillController = QuillController(
            document: Document.fromJson(
              List<Map<String, dynamic>>.from(jsonDecode(p.description)),
            ),
            selection: const TextSelection.collapsed(offset: 0),
          );
        }
      } catch (_) {}
    }
  }

  List<String> _asStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((item) => item?.toString() ?? "")
          .where((item) => item.isNotEmpty)
          .toList();
    }
    if (value is String && value.trim().isNotEmpty) return [value.trim()];
    return [];
  }

  List<String> _selectedValuesFor(AttributeModel? attribute) {
    if (attribute == null) return [];
    final match =
        selectedAttributes.where((a) => a["attributeId"] == attribute.id);
    if (match.isEmpty) return [];
    return _asStringList(match.first["values"]);
  }

  @override
  void dispose() {
    titleController.dispose();
    skuController.dispose();
    priceController.dispose();
    saleController.dispose();
    stockController.dispose();
    thumbnailController.dispose();
    _quillController.dispose();
    tagController.dispose();
    for (var c in imageControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, controller, _) {
        if (controller.brands.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.product == null ? "Tạo sản phẩm" : "Cập nhật sản phẩm",
            ),
          ),
          // GIẢI PHÁP: Bọc toàn bộ body bằng SingleChildScrollView
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ================= LEFT COLUMN (Main Content)=================
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        /// BASIC INFO
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Thông tin cơ bản",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                TextFormField(
                                  controller: titleController,
                                  decoration: const InputDecoration(
                                    labelText: "Tên sản phẩm",
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (v) => v == null || v.isEmpty
                                      ? "Bắt buộc"
                                      : null,
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  "Mô tả",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                QuillSimpleToolbar(
                                  controller: _quillController,
                                  config: const QuillSimpleToolbarConfig(),
                                ),
                                Container(
                                  height:
                                      300, // Tăng thêm không gian cho editor
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(8),
                                    ),
                                  ),
                                  child: QuillEditor(
                                    controller: _quillController,
                                    focusNode: FocusNode(),
                                    scrollController: ScrollController(),
                                    config: const QuillEditorConfig(
                                      padding: EdgeInsets.all(10),
                                      placeholder: "Nhập mô tả sản phẩm...",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        /// PRODUCT CONFIGURATION & MANAGEMENT
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Cấu hình & quản lý sản phẩm",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 15),

                                /// PRODUCT TYPE
                                const Text(
                                  "Loại sản phẩm",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: RadioListTile<ProductType>(
                                        value: ProductType.simple,
                                        groupValue: productType,
                                        onChanged: (value) {
                                          setState(() => productType = value!);
                                        },
                                        title: const Text("Đơn"),
                                      ),
                                    ),
                                    Expanded(
                                      child: RadioListTile<ProductType>(
                                        value: ProductType.variable,
                                        groupValue: productType,
                                        onChanged: (value) {
                                          setState(() => productType = value!);
                                        },
                                        title: const Text("Biến thể"),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),

                                /// SKU
                                TextFormField(
                                  controller: skuController,
                                  decoration: const InputDecoration(
                                    labelText: "Mã SKU",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 15),

                                /// STOCK
                                TextFormField(
                                  controller: stockController,
                                  keyboardType: TextInputType.number,
                                  enabled: productType == ProductType.simple,
                                  decoration: const InputDecoration(
                                    labelText: "Tồn kho",
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (v) {
                                    if (productType == ProductType.simple) {
                                      if (v == null || v.isEmpty)
                                        return "Vui lòng nhập tồn kho";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 15),

                                /// PRICE
                                TextFormField(
                                  controller: priceController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  enabled: productType == ProductType.simple,
                                  decoration: const InputDecoration(
                                    labelText: "Giá",
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (v) {
                                    if (productType == ProductType.simple) {
                                      if (v == null || v.isEmpty)
                                        return "Vui lòng nhập giá";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 15),

                                /// DISCOUNT PRICE
                                TextFormField(
                                  controller: saleController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  enabled: productType == ProductType.simple,
                                  decoration: const InputDecoration(
                                    labelText: "Giá giảm",
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (v) {
                                    if (v != null && v.isNotEmpty) {
                                      double? sale = double.tryParse(v);
                                      double? price = double.tryParse(
                                        priceController.text,
                                      );
                                      if (sale != null &&
                                          price != null &&
                                          sale > price) {
                                        return "Giá giảm phải <= giá";
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Ảnh bổ sung",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Wrap(
                                  spacing: 20,
                                  runSpacing: 20,
                                  children: List.generate(4, (index) {
                                    return SizedBox(
                                      width: 220,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Ảnh ${index + 1}"),
                                          const SizedBox(height: 8),

                                          /// IMAGE PREVIEW
                                          Container(
                                            height: 120,
                                            width: 220,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                            child:
                                                imageControllers[index]
                                                    .text
                                                    .isEmpty
                                                ? const Center(
                                                    child:
                                                        Text("Chưa có ảnh"),
                                                  )
                                                : Image.network(
                                                    imageControllers[index]
                                                        .text,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (_, __, ___) =>
                                                            const Center(
                                                              child: Text(
                                                                "URL không hợp lệ",
                                                              ),
                                                            ),
                                                  ),
                                          ),
                                          const SizedBox(height: 8),

                                          /// URL INPUT
                                          TextFormField(
                                            controller: imageControllers[index],
                                            decoration: InputDecoration(
                                              hintText: "Dán URL ảnh",
                                              border:
                                                  const OutlineInputBorder(),
                                              suffixIcon: IconButton(
                                                icon: const Icon(Icons.clear),
                                                onPressed: () {
                                                  imageControllers[index]
                                                      .clear();
                                                  setState(() {});
                                                },
                                              ),
                                            ),
                                            onChanged: (_) => setState(() {}),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Thuộc tính sản phẩm",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 15),

                                /// ATTRIBUTE DROPDOWN
                                DropdownButtonFormField<AttributeModel>(
                                  value: currentAttribute,
                                  decoration: const InputDecoration(
                                    labelText: "Chọn thuộc tính",
                                    border: OutlineInputBorder(),
                                  ),
                                  items: controller.attributes
                                      .map(
                                        (attr) => DropdownMenuItem(
                                          value: attr,
                                          child: Text(attr.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (attr) {
                                    setState(() {
                                      currentAttribute = attr;
                                      tempSelectedValues =
                                          _selectedValuesFor(attr);
                                    });
                                  },
                                ),
                                const SizedBox(height: 15),

                                /// VALUE CHECKBOX
                                if (currentAttribute != null)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currentAttribute!.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Wrap(
                                        spacing: 10,
                                        children: currentAttribute!
                                            .attributeValues
                                            .map(
                                              (val) => FilterChip(
                                                label: Text(val),
                                                selected: tempSelectedValues
                                                    .contains(val),
                                                onSelected: (checked) {
                                                  setState(() {
                                                    if (checked) {
                                                      tempSelectedValues.add(
                                                        val,
                                                      );
                                                    } else {
                                                      tempSelectedValues.remove(
                                                        val,
                                                      );
                                                    }
                                                  });
                                                },
                                              ),
                                            )
                                            .toList(),
                                      ),
                                      const SizedBox(height: 15),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (currentAttribute == null) return;
                                          setState(() {
                                            final existingIndex = selectedAttributes.indexWhere(
                                              (a) => a["attributeId"] == currentAttribute!.id,
                                            );
                                            if (tempSelectedValues.isEmpty) {
                                              if (existingIndex != -1) {
                                                selectedAttributes.removeAt(existingIndex);
                                              }
                                            } else {
                                              final entry = {
                                                "attributeId": currentAttribute!.id,
                                                "name": currentAttribute!.name,
                                                "values": List<String>.from(tempSelectedValues),
                                              };
                                              if (existingIndex == -1) {
                                                selectedAttributes.add(entry);
                                              } else {
                                                selectedAttributes[existingIndex] = entry;
                                              }
                                            }
                                            currentAttribute = null;
                                            tempSelectedValues.clear();
                                          });
                                        },
                                        child: Text(
                                          selectedAttributes.any((a) => a["attributeId"] == currentAttribute?.id)
                                              ? "Cập nhật thuộc tính"
                                              : "Thêm thuộc tính",
                                        ),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 20),

                                /// SELECTED ATTRIBUTE LIST
                                ...selectedAttributes.map(
                                  (attr) => Card(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: ListTile(
                                      title: Text(attr["name"] ?? ""),
                                      subtitle: Text(
                                        _asStringList(attr["values"]).join(", "),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () {
                                              final matchingAttr = controller.attributes
                                                  .where((a) => a.id == attr["attributeId"])
                                                  .firstOrNull;
                                              if (matchingAttr != null) {
                                                setState(() {
                                                  currentAttribute = matchingAttr;
                                                  tempSelectedValues = List<String>.from(_asStringList(attr["values"]));
                                                });
                                              }
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                selectedAttributes.remove(attr);
                                                if (currentAttribute?.id == attr["attributeId"]) {
                                                  currentAttribute = null;
                                                  tempSelectedValues.clear();
                                                }
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        final matchingAttr = controller.attributes
                                            .where((a) => a.id == attr["attributeId"])
                                            .firstOrNull;
                                        if (matchingAttr != null) {
                                          setState(() {
                                            currentAttribute = matchingAttr;
                                            tempSelectedValues = List<String>.from(_asStringList(attr["values"]));
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),

                  /// ================= RIGHT COLUMN (Settings)=================
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        /// VISIBILITY & THUMBNAIL
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Trạng thái",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                RadioListTile<bool>(
                                  value: false,
                                  groupValue: isDraft,
                                  onChanged: (v) =>
                                      setState(() => isDraft = v!),
                                  title: const Text("Đăng"),
                                ),
                                RadioListTile<bool>(
                                  value: true,
                                  groupValue: isDraft,
                                  onChanged: (v) =>
                                      setState(() => isDraft = v!),
                                  title: const Text("Nháp"),
                                ),
                                const Divider(),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: thumbnailController,
                                  decoration: const InputDecoration(
                                    labelText: "URL ảnh đại diện",
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                                const SizedBox(height: 10),
                                if (thumbnailController.text.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      thumbnailController.text,
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.broken_image,
                                                size: 50,
                                              ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        /// BRAND
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: DropdownButtonFormField<String>(
                              value: selectedBrandId,
                              items: controller.brands
                                  .map(
                                    (b) => DropdownMenuItem(
                                      value: b.id,
                                      child: Text(b.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => selectedBrandId = v),
                              decoration: const InputDecoration(
                                labelText: "Thương hiệu",
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) =>
                                  v == null ? "Chọn thương hiệu" : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        /// CATEGORIES
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Danh mục",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                ...controller.categories.map(
                                  (cat) => CheckboxListTile(
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    value: selectedCategoryIds.contains(cat.id),
                                    title: Text(cat.name),
                                    onChanged: (checked) {
                                      setState(() {
                                        if (checked!) {
                                          selectedCategoryIds.add(cat.id);
                                        } else {
                                          selectedCategoryIds.remove(cat.id);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Thẻ sản phẩm",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                TextFormField(
                                  controller: tagController,
                                  decoration: const InputDecoration(
                                    labelText: "Nhập thẻ (a,b,c,...)",
                                    border: OutlineInputBorder(),
                                    hintText: "mua he, ao, moi",
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  children: tagController.text
                                      .split(',')
                                      .map((e) => e.trim())
                                      .where((e) => e.isNotEmpty)
                                      .map((tag) => Chip(label: Text(tag)))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        /// SAVE BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) return;
                              final product = ProductModel(
                                id: widget.product?.id ?? "",
                                title: titleController.text,
                                price:
                                    double.tryParse(priceController.text) ?? 0,
                                salePrice: double.tryParse(saleController.text),
                                thumbnail: thumbnailController.text,
                                productType: productType,
                                stock: productType == ProductType.simple
                                    ? int.tryParse(stockController.text) ?? 0
                                    : 0,
                                soldQuantity: widget.product?.soldQuantity ?? 0,
                                isActive: !isDraft,
                                isDraft: isDraft,
                                isDeleted: false,
                                images: imageControllers
                                    .map((c) => c.text.trim())
                                    .where((url) => url.isNotEmpty)
                                    .toList(),
                                sku: skuController.text,

                                /// FIX QUILL
                                description: jsonEncode(
                                  _quillController.document.toDelta().toJson(),
                                ),
                                brandId: selectedBrandId,
                                categoryIds: selectedCategoryIds,
                                tags: tagController.text
                                    .split(',')
                                    .map((e) => e.trim())
                                    .where((e) => e.isNotEmpty)
                                    .toList(),
                                attributes: selectedAttributes,
                                variations: widget.product?.variations,

                                /// 🔥 default fields (important)
                                isFeatured: widget.product?.isFeatured ?? false,
                                isRecommended:
                                    widget.product?.isRecommended ?? false,
                                views: widget.product?.views ?? 0,
                                rating: widget.product?.rating ?? 0,
                                ratingCount: widget.product?.ratingCount ?? 0,
                                reviewsCount: widget.product?.reviewsCount ?? 0,
                                fiveStarCount:
                                    widget.product?.fiveStarCount ?? 0,
                                fourStarCount:
                                    widget.product?.fourStarCount ?? 0,
                                threeStarCount:
                                    widget.product?.threeStarCount ?? 0,
                                twoStarCount: widget.product?.twoStarCount ?? 0,
                                oneStarCount: widget.product?.oneStarCount ?? 0,
                                likes: widget.product?.likes ?? 0,
                              );
                              await controller.save(
                                product,
                                isUpdate: widget.product != null,
                              );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Lưu sản phẩm thành công"),
                                  ),
                                );
                                Navigator.pop(context);
                              }
                            },
                            child: const Text(
                              "LƯU SẢN PHẨM",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
