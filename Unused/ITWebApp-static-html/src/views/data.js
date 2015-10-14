var marked = require('marked');

var branches = [
  {
    name: 'Chelsea Market',
  },
  {
    name: 'Battery Park',
  },
  {
    name: 'Williamsburg',
  },
];

var offers = [
  {
    offerName: 'Jeans and shirt',
    offerDesc: 'Get the best jeans in town for the lowest prices!!',
    branchId: 1,
    branchName: 'Chelsea Market',
    retailerId: 420,
    custLimit: 10,
    discLimit: 10,
    custType: 'New customore',
  },
  {
    offerName: 'Cats and dogs',
    offerDesc: 'Get the cutest cats in town for the lowest prices!!',
    branchId: 1,
    branchName: 'Chelsea Market',
    retailerId: 420,
    custLimit: 12,
    discLimit: 10,
    custType: 'New customore',
  },
];

module.exports = {
  branches: branches,
  offers: offers
};
