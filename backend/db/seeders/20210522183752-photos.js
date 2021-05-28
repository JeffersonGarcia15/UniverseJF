'use strict';

module.exports = {
  up: (queryInterface, Sequelize) => {
    return queryInterface.bulkInsert('Photos', [
      { title: "Gliese 667Cc", description: "Earth Siblings", imgUrl: "https://universejf.s3.us-east-2.amazonaws.com/gliese-667cc.jpg", userId: 1 },
      { title: "Kepler-22b", description: "Earth Siblings", imgUrl: "https://universejf.s3.us-east-2.amazonaws.com/607694main_Kepler22bArtwork_full.jpg", userId: 1 },
      { title: "Kepler-69c", description: "Earth Siblings", imgUrl: "https://universejf.s3.us-east-2.amazonaws.com/742553main_Kepler69c_full.jpg", userId: 1 },
      { title: "Saturn", description: "Earth Friend", imgUrl: "https://universejf.s3.us-east-2.amazonaws.com/160416.jpg", userId: 1 },
      { title: "Titan", description: "Earth Siblings", imgUrl: "https://universejf.s3.us-east-2.amazonaws.com/1624411.jpg", userId: 1 },
      { title: "Andromeda", description: "Galaxy", imgUrl: "https://universejf.s3.us-east-2.amazonaws.com/184-1844616_ultra-hd-4k-space.jpg", userId: 1 },
      { title: "A cool galaxy", description: "Some other galaxy", imgUrl: "https://universejf.s3.us-east-2.amazonaws.com/186-1867583_cool-galaxy-wallpapers-high-resolution-ultra-hd.jpg", userId: 1 },
      { title: "Canis Major Dwarf Galaxy", description: "A close galaxy", imgUrl: "https://universejf.s3.us-east-2.amazonaws.com/202054.jpg", userId: 1 },
      { title: "Yet another galaxy", description: "Same as title", imgUrl: "https://universejf.s3.us-east-2.amazonaws.com/202059.jpg", userId: 1 },
      { title: "Cool planet", description: "Cool looking planet", imgUrl: "https://universejf.s3.us-east-2.amazonaws.com/452b_artistconcept_beautyshot.jpg", userId: 1 },
      { title: "gliese1214b", description: "Scary planet", imgUrl: "https://universejf.s3.us-east-2.amazonaws.com/gliese1214b.jpg", userId: 1 },
      { title: "Jupiter Planet", description: "Jupiter", imgUrl: "https://universejf.s3.us-east-2.amazonaws.com/HD-80606-B.webp", userId: 1 },
      { title: "Another Diamond Planet", description: "Rich planet", imgUrl: "https://universejf.s3.us-east-2.amazonaws.com/Kepler-78b.webp", userId: 1 },
      { title: "Mars", description: "Cool Planet", imgUrl: "https://universejf.s3.us-east-2.amazonaws.com/mars.jpg", userId: 1 },
      { title: "Mercury", description: "Just Mercury", imgUrl: "https://universejf.s3.us-east-2.amazonaws.com/mercury.jpg", userId: 1 },
      { title: "Milky Way", description: "Galaxy", imgUrl: "https://universejf.s3.us-east-2.amazonaws.com/milky_way_starry_sky_galaxy_119519_3840x2160.jpg", userId: 1 },
      { title: "Mysterious Planet", description: "Some weird but beautiful planet", imgUrl: "https://universejf.s3.us-east-2.amazonaws.com/photo-1545156521-77bd85671d30.webp", userId: 1 },
      { title: "Another moon?", description: "Looks like moon", imgUrl: "https://universejf.s3.us-east-2.amazonaws.com/photo-1589225529399-8705282f98e2.webp", userId: 1 },
      { title: "Water Planet", description: "Life on this planet?", imgUrl: "https://universejf.s3.us-east-2.amazonaws.com/photo-1590821695525-1e86ef70a7ee.webp", userId: 1 },
      { title: "Drawing of a Planet", description: "Drawing", imgUrl: "https://s3.console.aws.amazon.com/s3/object/universejf?region=us-east-2&prefix=photo-1590907043334-8eba76905b92.webp", userId: 1 },
      { title: "Venus", description: "Simply Venus", imgUrl: "https://universejf.s3.us-east-2.amazonaws.com/venus.jpg", userId: 1 },
      { title: "Kepler-62f", description: "Planet that looks like Earth", imgUrl: "https://universejf.s3.us-east-2.amazonaws.com/742529main_Kepler62f_full.jpg", userId: 2 },
      { title: "Kepler-186f", description: 'Planet photo', imgUrl: "https://universejf.s3.us-east-2.amazonaws.com/kepler186f_artistconcept_2.jpg", userId: 3 },
      { title: "Kepler-452b", description: 'A random planet', imgUrl: "https://universejf.s3.us-east-2.amazonaws.com/452b_artistconcept_beautyshot.jpg", userId: 4 },
    ])
  },

  down: (queryInterface, Sequelize) => {
    /*
      Add reverting commands here.
      Return a promise to correctly handle asynchronicity.

      Example:
      return queryInterface.bulkDelete('People', null, {});
    */
   return queryInterface.bulkDelete('Photos', null, {});
  }
};
