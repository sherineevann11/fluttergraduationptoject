import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:graduationproject/core/style/app_assets.dart';
import 'package:graduationproject/core/widgets/TextField_button.dart';
import 'package:graduationproject/core/widgets/custom_back_button.dart';
import 'package:graduationproject/features/auth/controller/auth_controller.dart';

class ProfileScreenBody extends StatefulWidget {
  const ProfileScreenBody({super.key});

  @override
  State<ProfileScreenBody> createState() => _ProfileScreenBodyState();
}

class _ProfileScreenBodyState extends State<ProfileScreenBody> {
  final AuthController controller = Get.find<AuthController>();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  String? _base64Image;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final data = await controller.getUserProfile();
    if (data != null) {
      setState(() {
        _nameController.text = data['fullName'] ?? '';
        _usernameController.text = data['userName'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phoneNumber'] ?? '';
        _base64Image = data['userBase64Image'];
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image == null) return;

    final bytes = await image.readAsBytes();

    setState(() {
      _selectedImageBytes = bytes;
      if (!kIsWeb) {
        _selectedImage = File(image.path);
      }
    });

    if (kIsWeb) {
      await controller.updateUserImageBytes(bytes);
    } else {
      await controller.updateUserImage(image.path);
    }
  }

  ImageProvider _getImageProvider() {
    if (_selectedImageBytes != null) {
      return MemoryImage(_selectedImageBytes!);
    } else if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    } else if (_base64Image != null && _base64Image!.isNotEmpty) {
      return MemoryImage(base64Decode(_base64Image!));
    }
    return const AssetImage('assets/images/welcome image.png');
  }

  bool _hasImage() {
    return _selectedImageBytes != null ||
        _selectedImage != null ||
        (_base64Image != null && _base64Image!.isNotEmpty);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            height: 180.h,
            child: Stack(
              children: [
                Positioned(
                  top: 10.h,
                  left: 10.w,
                  child: CustomBackButton(),
                ),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      /// الدائرة الخارجية
                      Container(
                        width: 110.w,
                        height: 110.h,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1C6E93),
                          shape: BoxShape.circle,
                        ),
                      ),

                      /// الصورة أو placeholder
                      Container(
                        width: 95.w,
                        height: 95.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                          image: _hasImage()
                              ? DecorationImage(
                                  image: _getImageProvider(),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: !_hasImage()
                            ? Icon(
                                Icons.person,
                                size: 50.sp,
                                color: Colors.grey[500],
                              )
                            : null,
                      ),

                      /// أيقونة الكاميرا
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 30.w,
                            height: 30.h,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: SvgPicture.asset(
                              AppAssets.CameraIcon,
                              colorFilter: const ColorFilter.mode(
                                Color(0xFF1C6E93),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.w),
            child: Column(
              children: [
                CustomTextField(
                  label: 'الاسم',
                  hintText: 'أدخل اسمك',
                  controller: _nameController,
                ),
                SizedBox(height: 20.h),
                CustomTextField(
                  label: 'اسم المستخدم',
                  hintText: 'أدخل اسم المستخدم',
                  controller: _usernameController,
                ),
                SizedBox(height: 20.h),
                CustomTextField(
                  label: 'البريد الإلكتروني',
                  hintText: 'أدخل بريدك الإلكتروني',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20.h),
                CustomTextField(
                  label: 'رقم الهاتف',
                  hintText: 'أدخل رقم هاتفك',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 40.h),

                Obx(() => SizedBox(
                      width: double.infinity,
                      height: 55.h,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => controller.updateUserProfile(
                                  fullName: _nameController.text,
                                  email: _emailController.text,
                                  phoneNumber: _phoneController.text,
                                  userName: _usernameController.text,
                                ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF30BBF9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35.r),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'حفظ التغييرات',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    )),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}