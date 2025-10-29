// controllers\users.controller.js
const User = require('../models/users.model');
const bcrypt = require('bcryptjs');
const path = require('path');
const fs = require('fs');

// Thêm user
exports.addUser = async (req, res) => {
  try {
    const { username, email, password } = req.body;
    let imagePath = '';

    if (req.file) {
      imagePath = `/assets/${req.file.filename}`;
    }

    // const hashedPassword = await bcrypt.hash(password, 10);

    const newUser = new User({
      username,
      email,
      // password: hashedPassword,
      password,
      image: imagePath,
    });

    const savedUser = await newUser.save();
    res.status(201).json({ success: true, data: savedUser });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// Lấy danh sách tất cả user
exports.getUsers = async (req, res) => {
  try {
    const users = await User.find().sort({ createdAt: -1 });
    res.json(users);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Sửa user
exports.updateUser = async (req, res) => {
  try {
    const { email } = req.params;
    const { username, password } = req.body;
    const user = await User.findOne({ email });

    if (!user) return res.status(404).json({ message: 'User not found' });

    if (username) user.username = username;
    
    if (password) {
      // user.password = await bcrypt.hash(password, 10);
      user.password = password;
    }

    if (req.file) {
      if (user.image) {
        const oldImagePath = path.join(__dirname, '../', user.image);
        if (fs.existsSync(oldImagePath)) fs.unlinkSync(oldImagePath);
      }
      user.image = `/assets/${req.file.filename}`;
    }

    const updatedUser = await user.save();
    res.json({ success: true, data: updatedUser });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// Xóa user theo email
exports.deleteUser = async (req, res) => {
  try {
    const { email } = req.params;
    const user = await User.findOne({ email });

    if (!user) return res.status(404).json({ message: 'User not found' });

    if (user.image) {
      const imagePath = path.join(__dirname, '../', user.image);
      if (fs.existsSync(imagePath)) fs.unlinkSync(imagePath);
    }

    await User.deleteOne({ email });
    res.json({ success: true, message: 'User deleted successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
