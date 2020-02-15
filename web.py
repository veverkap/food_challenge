import falcon


class Resource:
    def on_post(self, req, resp):
        """Handles POST requests"""
        quote = {
            'quote': (
                "I've always been more interested in "
                "the future than in the past."
            ),
            'author': 'Grace Hopper'
        }

        resp.media = quote


api = falcon.API()
api.add_route('/detect', Resource())
