const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// ==================== DATABASE (In-Memory) ====================
let users = [
  { id: 1, name: 'John Doe', email: 'john@example.com', role: 'Admin' },
  { id: 2, name: 'Jane Smith', email: 'jane@example.com', role: 'User' },
  { id: 3, name: 'Bob Johnson', email: 'bob@example.com', role: 'User' }
];

let nextId = 4;

// ==================== BACKEND API ENDPOINTS ====================

// Health Check
app.get('/api/health', (req, res) => {
  res.json({ status: 'Server is running!', timestamp: new Date() });
});

// Get all users (READ)
app.get('/api/users', (req, res) => {
  res.json({
    success: true,
    data: users,
    count: users.length
  });
});

// Get user by ID (READ)
app.get('/api/users/:id', (req, res) => {
  const user = users.find(u => u.id === parseInt(req.params.id));
  if (!user) {
    return res.status(404).json({ success: false, message: 'User not found' });
  }
  res.json({ success: true, data: user });
});

// Create new user (CREATE)
app.post('/api/users', (req, res) => {
  const { name, email, role } = req.body;

  if (!name || !email || !role) {
    return res.status(400).json({ 
      success: false, 
      message: 'Name, email, and role are required' 
    });
  }

  const newUser = {
    id: nextId++,
    name,
    email,
    role
  };

  users.push(newUser);
  res.status(201).json({ success: true, data: newUser, message: 'User created' });
});

// Update user (UPDATE)
app.put('/api/users/:id', (req, res) => {
  const user = users.find(u => u.id === parseInt(req.params.id));
  
  if (!user) {
    return res.status(404).json({ success: false, message: 'User not found' });
  }

  const { name, email, role } = req.body;
  if (name) user.name = name;
  if (email) user.email = email;
  if (role) user.role = role;

  res.json({ success: true, data: user, message: 'User updated' });
});

// Delete user (DELETE)
app.delete('/api/users/:id', (req, res) => {
  const index = users.findIndex(u => u.id === parseInt(req.params.id));
  
  if (index === -1) {
    return res.status(404).json({ success: false, message: 'User not found' });
  }

  const deletedUser = users.splice(index, 1);
  res.json({ success: true, data: deletedUser[0], message: 'User deleted' });
});

// ==================== FRONTEND ROUTES ====================

// Serve index.html for the main page
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// 404 Handler
app.use((req, res) => {
  res.status(404).json({ success: false, message: 'Route not found' });
});

// ==================== START SERVER ====================
app.listen(PORT, () => {
  console.log(`========================================`);
  console.log(`🚀 2-Tier Application is running!`);
  console.log(`📱 Frontend: http://localhost:${PORT}`);
  console.log(`🔌 API: http://localhost:${PORT}/api`);
  console.log(`========================================`);
  console.log(`Available endpoints:`);
  console.log(`  GET  /api/health`);
  console.log(`  GET  /api/users`);
  console.log(`  GET  /api/users/:id`);
  console.log(`  POST /api/users`);
  console.log(`  PUT  /api/users/:id`);
  console.log(`  DELETE /api/users/:id`);
  console.log(`========================================`);
});