# Welcome to UniverseJF

## Live link: [UniverseJF](https://universejf.herokuapp.com/)

[UniverseJF](https://universejf.herokuapp.com/), inspired by [flicker](https://www.flickr.com/), is a web application that allows users to post pictures of their favorite planets, galaxy or anything universe/space related. As a registered user you can post photos with tags, create albums, follow users, like photos and add comments on photos. And even if you have not registered, you can see the best pictures in the slash page.

#

## Table of content

1. [Getting Started](https://github.com/JeffersonGarcia15/UniverseJF#getting-started)
2. [Technologies Used](https://github.com/JeffersonGarcia15/UniverseJF#technologies-used)
3. [Key Features](https://github.com/JeffersonGarcia15/UniverseJF#key-features)
4. [Code Snippets](https://github.com/JeffersonGarcia15/UniverseJF#code-snippets)
5. [Wiki](https://github.com/JeffersonGarcia15/UniverseJF#wikii)
6. [Future Goals](https://github.com/JeffersonGarcia15/UniverseJF#future-goals)

#

## Getting Started

1. Clone this repository
2. Install dependencies (`npm install`)
3. Create a `.env` file based on the `.env.example` and replace the value of `SESSION_SECRET` with your own `SESSION_SECRET` value. You can generate a value by using [UUID](https://www.npmjs.com/package/uuid) to have a more secure value.
4. Set up your PostgreSQL ddiy_app user, a password and database and make sure it matches the `.env` file. Make sure to give CREATEDB privileges to your ddiy_app user.
5. Enter the following commands:

```
npx dotenv sequelize-cli db:create
npx dotenv sequelize-cli db:migrate
npx dotenv sequelize-cli db:seed:all
npm start
```

#

## Technologies Used

**Front End**

- JavaScript
- HTML
- CSS
- [Favicon.io](https://favicon.io)
- [Fontawesome](http://fontawesome.com/)
- React
- Redux
- Heroku

**Back End**

- Express.js
- Sequelize.js
- Faker.js
- Node.js
- Bcryptjs
- PostgreSQL and Postbird
- AJAX
- AWS

#

## Key Features

- Users can view, upload, edit and delete photos
- Users can view, post, edit and delete comments
- Users can create albums for their photos
- Users can add tags to photos and see all photos with an associated tag
- Users can like another user's photos

#

## Quick tour

[Sign up](https://youtu.be/SO-sTS-QVtc)

[Comments and photo likes](https://youtu.be/gfS-gwrA9vI)

[Albums](https://youtu.be/4LIo-ekTkPo)

[Photo and tag creation](https://youtu.be/H-vK3_ttoHU)

[Photo update and deletion](https://youtu.be/3Z_79APk9VM)

[Footer](https://youtu.be/A34O0y4xgHk)

[User edits](https://youtu.be/EYMdoKuDckg)

## Code Snippets

_Creating a tag by simply pressing "Enter"_

```js
function handleKeyDown(e) {
  if (e.key === "Enter" && tagTitle.trim() !== "") {
    e.preventDefault();
    setTagsArray((prev) => {
      return [...prev, tagTitle];
    });
    setTagTitle("");
  }
}
```

_Creating tags by sending an array of tags, to the backend, which would then check which tags exist, and the ones that don't exists will be created and the rest will simply be returned to avoid duplicating tags_

Here I also used `Promise.all` rather than doing a for loop and sending a fetch request in order to optimize the fetch request with the help of that promise method.

```js
const onSubmit = async (e) => {
  e.preventDefault();

  const photo = await dispatch(
    uploadSinglePhoto({
      title,
      description,
      imgUrl,
      userId: sessionUser.id,
    })
  );

  // Send the entire array of tags to the backend in a single request
  const tagsResponse = await dispatch(createTag({ tagsArray }));

  // Assign tags to the photo
  await Promise.all(
    tagsResponse.map(({ id }) =>
      dispatch(addUserTagToPhoto({ tagId: id, photoId: photo.id }))
    )
  );

  await dispatch(addUserPhotoToAlbum(addPhotoAlbum, photo));

  setShowMenu(false);
  setTitle("");
  setDescription("");
  setTagsArray([]);
  setTagTitle("");
};
```

#

## Wiki

[API Documentation](https://github.com/JeffersonGarcia15/UniverseJF/wiki/API-Documentation)

[Feature List](https://github.com/JeffersonGarcia15/UniverseJF/wiki/MVP-Feature-List)

[Frontend Routes](https://github.com/JeffersonGarcia15/UniverseJF/wiki/Frontend-Routes)

[Schema](https://github.com/JeffersonGarcia15/UniverseJF/wiki/Database-Schema)

[User Stories](https://github.com/JeffersonGarcia15/UniverseJF/wiki/User-Stories)

![](https://live.staticflickr.com/65535/51190674126_888c2b4b52_k.jpg)

#

## Future Goals

- Explore by tags(so photos that include a certain tag will appear with all photos using that tag)
- UI Improvement and refactoring overall!
- Creating an album requires a photo
- Adding the same photo to multiple albums
- Tags suggestions for photos
- Search albums during album selections
- Search tags during tag selections
- Newly designed landing page
- Newly designed login and signup pages
- Newly designed UI for the photo details page
- Implement followers
