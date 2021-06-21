import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { useParams, useHistory } from 'react-router-dom';
import { createTag } from '../../store/tags'



function Tags() {
    const dispatch = useDispatch()
    const { userId } = useParams()
    const user = useSelector(state => state.session.user)
    const albums = useSelector(state => state.albums)



}


export default Tags