class Rectangle:
    def __init__(self, pt1, pt2):
        self.set_points(pt1, pt2)

    def set_points(self, pt1, pt2):
        (x1, y1) = pt1
        (x2, y2) = pt2
        self.left = min(x1, x2)
        self.top = min(y1, y2)
        self.right = max(x1, x2)
        self.bottom = max(y1, y2)

    def overlaps(self, other):
        """Return true if a rectangle overlaps this rectangle."""
        return (self.right > other.left and self.left < other.right and
                self.top < other.bottom and self.bottom > other.top)
