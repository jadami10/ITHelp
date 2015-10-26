var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('login', { title: 'Log In - BriskIT' }); 
});

router.get('/solve', function(req, res, next) {
  res.render('solve', { title: 'Solve a problem - BriskIT' }); 
});

router.get('/solving', function(req, res, next) {
  res.render('solving', { title: 'Problems currently solving - BriskIT' }); 
});

router.get('/chatting/:id', function(req, res) {
  res.render('chatting', { title: 'Chatting... - BriskIT' }); 
});

module.exports = router;
