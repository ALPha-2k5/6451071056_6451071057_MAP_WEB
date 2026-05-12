import 'package:flutter/material.dart';
import '../../data/models/attribute_model.dart';
import '../../data/services/attribute_service.dart';

class AttributeFormPage extends StatefulWidget {
  final AttributeModel? attribute;
  const AttributeFormPage({super.key, this.attribute});
  @override
  State<AttributeFormPage> createState() => _AttributeFormPageState();
}

class _AttributeFormPageState extends State<AttributeFormPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final valueController = TextEditingController();
  bool isActive = true;
  bool isSearchable = false;
  bool isFilterable = false;
  bool isColorAttribute = false;
  final service = AttributeService();
  @override
  void initState() {
    super.initState();
    if (widget.attribute != null) {
      final a = widget.attribute!;
      nameController.text = a.name;
      valueController.text = a.attributeValues.join("|");
      isActive = a.isActive;
      isSearchable = widget.attribute?.isSearchable ?? false;
      isFilterable = a.isFilterable;
      isColorAttribute = a.isColorAttribute;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.attribute == null ? "Create Attribute" : "Update Attribute",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextFormField(
                controller: valueController,
                decoration: const InputDecoration(
                  labelText: "Values (small|medium|big)",
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text("Active"),
                      value: isActive,
                      onChanged: (v) => setState(() => isActive = v!),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text("Searchable"),
                      value: isSearchable,
                      onChanged: (v) => setState(() => isSearchable = v!),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message:
                        "Allow user to filter product based on this attribute",
                    child: const Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  final values = valueController.text.split("|");
                  final model = AttributeModel(
                    id: widget.attribute?.id ?? "",
                    name: nameController.text,
                    attributeValues: values,
                    isActive: isActive,
                    isSearchable: isSearchable,
                    isFilterable: isFilterable,
                    isColorAttribute: isColorAttribute,
                  );
                  if (widget.attribute == null) {
                    await service.create(model);
                  } else {
                    await service.update(model);
                  }
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
