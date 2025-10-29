// routes\users.route.js
const express = require('express');
const router = express.Router();
const { addUser, getUsers, updateUser, deleteUser } = require('../controllers/users.controller');
const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'assets/'),
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  },
});

const upload = multer({ storage });

router.post('/', upload.single('image'), addUser);
router.get('/', getUsers);
router.put('/:email', upload.single('image'), updateUser);
router.delete('/:email', deleteUser);

module.exports = router;


