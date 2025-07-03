import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user_model.dart';

class ProfileView extends StatefulWidget {
  final AppUser? user;
  const ProfileView({super.key, this.user});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool isEditing = false;
  final _formKey = GlobalKey<FormState>();
  File? _profileImage;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _nameController.text = '${widget.user!.name} ${widget.user!.surname}';
      _emailController.text = widget.user!.email;
      _phoneController.text = widget.user!.userData['telefon']?.toString() ?? '';
      _languageController.text = (widget.user!.userData['konusulanDiller'] is List)
        ? (widget.user!.userData['konusulanDiller'] as List).join(', ')
        : (widget.user!.userData['konusulanDiller']?.toString() ?? '');
      _aboutController.text = widget.user!.userData['hakkinda']?.toString() ?? '';
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      // Hata durumunda kullanıcıya bilgi ver
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fotoğraff seçiliirken bir hata oluştu')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final darkGreen = const Color(0xFF22543D);
    const text = const Text(
                          'Hakkımda',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: isDark ? darkGreen : const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: isDark ? darkGreen : const Color(0xFF2E7D32),
                      backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                      child: _profileImage == null
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          )
                        : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? darkGreen : const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Card(
                  color: theme.cardColor,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildTextField(
                          'İsim Soyisim',
                          _nameController,
                          Icons.person_outline,
                          iconColor: isDark ? darkGreen : const Color(0xFF2E7D32),
                          textColor: isDark ? darkGreen : const Color(0xFF1B5E20),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          'E-posta',
                          _emailController,
                          Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          iconColor: isDark ? darkGreen : const Color(0xFF2E7D32),
                          textColor: isDark ? darkGreen : const Color(0xFF1B5E20),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          'Telefon',
                          _phoneController,
                          Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          iconColor: isDark ? darkGreen : const Color(0xFF2E7D32),
                          textColor: isDark ? darkGreen : const Color(0xFF1B5E20),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          'Dil',
                          _languageController,
                          Icons.language_outlined,
                          iconColor: isDark ? darkGreen : const Color(0xFF2E7D32),
                          textColor: isDark ? darkGreen : const Color(0xFF1B5E20),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: theme.cardColor,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hakkımda',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? darkGreen : const Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _aboutController,
                          maxLines: 4,
                          enabled: isEditing,
                          decoration: InputDecoration(
                            hintText: 'Kendinizden bahsedin..',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: isDark ? darkGreen : const Color(0xFF2E7D32)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? darkGreen : const Color(0xFF2E7D32),
                    ),
                    onPressed: () {
                      setState(() {
                        if (isEditing && _formKey.currentState!.validate()) {
                          // Kaydetme işlemi başarılı olduğunda bildirim göster
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profil başarıyla güncellendi'),
                              backgroundColor: Color.fromARGB(255, 13, 13, 13),
                            ),
                          );
                          isEditing = false;
                        } else {
                          isEditing = true;
                        }
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isEditing ? Icons.save_outlined : Icons.edit_outlined,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isEditing ? 'Kaydet' : 'Profili Düzenle',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
    Color? iconColor,
    Color? textColor,
  }) {
    return TextFormField(
      controller: controller,
      enabled: isEditing,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: '$label giriniz',
        prefixIcon: Icon(icon, color: iconColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textColor!),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label boş bırakılamaz';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _languageController.dispose();
    _aboutController.dispose();
    super.dispose();
  }
} 