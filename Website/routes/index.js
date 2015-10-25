var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('solve', { title: 'Solve a problem' }); 
});

router.get('/solve', function(req, res, next) {
  res.render('solve', { title: 'Solve a problem' }); 
});

router.get('/solving', function(req, res, next) {
  res.render('solving', { title: 'Solving...' }); 
});

router.get('/chatting/:id', function(req, res) {
  res.render('chatting', { title: 'Chatting...' }); 
});

module.exports = router;
