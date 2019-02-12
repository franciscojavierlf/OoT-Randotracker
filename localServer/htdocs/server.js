
/**
 * Requests for the server.
 */
const Server = {

    // Hears constantly
    __timer: null,

    /**
     * Starts to hear the server.
     */
    start: () => {
        // Clears any old interval
        Server.stop()
        
        Server.__timer = setInterval(() => {
            Server.listen({ req: 'item', name: 'rupees'}, (res) => console.log(res))
        }, 200)
    },

    /**
     * Stops hearing the server.
     */
    stop: () => {
        clearInterval(Server.__timer)
    },

    /**
     * Listens to changes in the game.
     */
    listen: (query, f) => {
        let rawFile = new XMLHttpRequest()
        rawFile.onreadystatechange = function() {
            if (rawFile.readyState === 4 && rawFile.status == "200") {
                f(rawFile.responseText)
            }
        }
        rawFile.open('GET', 'data?' + Query.toString(query), true)
        rawFile.send()
    },
}

/**
 * A query class.
 */
class Query {
    /**
     * Returns a string of the query.
     */
    static toString(query) {
        let res = ''
        for (let key in query)
            res += key + '=' + query[key] + '&'
        // Removes last ampersand
        return res.substring(0, res.length - 1)
    }
}