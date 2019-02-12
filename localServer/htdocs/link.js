/**
 * Gets information of link.
 */

const Link = {

    /**
     * Processes a query and returns the result.
     */
    processQuery: (query, f) => {
        Server.listen(new Query(query), res => f(res))
    },
    

    /**
     * A small database.
     */

    stats: {
        rupees: { req: 'item', name: 'rupees' }
    },
    
    inventory: {
        ocarina: { req: 'item', name: 'ocarina' }
    }
}