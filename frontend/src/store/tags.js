import { csrfFetch } from './csrf'

const LOAD_ALL_TAGS = 'tags/LOAD_ALL_TAGS'



const loadTags = tags => {
    return {
        type: LOAD_ALL_TAGS,
        tags
    }
}

