import java.util.*;

class Rectangle {
  float x;
  float y;
  float w;
  float h;

  Rectangle() {
    this.x = 0;
    this.y = 0;
    this.w = 0;
    this.h = 0;
  }

  Rectangle(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  PVector tl() {
    return new PVector(x, y);
  }

  PVector tr() {
    return new PVector(x + w, y);
  }

  PVector bl() {
    return new PVector(x, y + h);
  }

  PVector br() {
    return new PVector(x + w, y + h);
  }

  void draw() {
    rect(x, y, w, h);
  }

  String toString() {
    return "rect:{x:" + x + ", y:" + y + ", w:" + w + ", h:" + h + "}";
  }
}

class Circle {
  DelaunayTriangulation d;

  PVector center;
  float r;

  Circle(DelaunayTriangulation d, int vi0, int vi1, int vi2) {
    this.d = d;

    PVector v0 = d.getV(vi0);
    PVector v1 = d.getV(vi1);
    PVector v2 = d.getV(vi2);

    float x1 = v0.x;  
    float y1 = v0.y;  
    float x2 = v1.x;  
    float y2 = v1.y;  
    float x3 = v2.x;  
    float y3 = v2.y;  
    float x1_2 = x1 * x1;
    float y1_2 = y1 * y1;
    float x2_2 = x2 * x2;
    float y2_2 = y2 * y2;
    float x3_2 = x3 * x3;
    float y3_2 = y3 * y3;

    float c = 2.0f * ((x2 - x1) * (y3 - y1) - (y2 - y1) * (x3 - x1));  
    float x = ((y3 - y1) * (x2_2 - x1_2 + y2_2 - y1_2) + (y1 - y2) * (x3_2 - x1_2 + y3_2 - y1_2)) / c;  
    float y = ((x1 - x3) * (x2_2 - x1_2 + y2_2 - y1_2) + (x2 - x1) * (x3_2 - x1_2 + y3_2 - y1_2)) / c;  

    this.center = new PVector(x, y);    
    this.r = PVector.dist(center, v0);
  }

  boolean isInner(int vi) {
    return isInner(d.getV(vi));
  }

  boolean isInner(PVector v) {
    float d = PVector.dist(v, center);
    if (d < r) return true; // 線上はfalse
    return false;
  }

  void draw() {
    ellipseMode(CENTER);
    ellipse(center.x, center.y, 2 * r, 2 * r);
  }
}

class Triangle {
  DelaunayTriangulation d;

  int [] vi = new int[3];

  Triangle(DelaunayTriangulation d, int vi0, int vi1, int vi2) {
    this.d = d;
    vi[0] = vi0;
    vi[1] = vi1;
    vi[2] = vi2;
  }

  Triangle(DelaunayTriangulation d, PVector v0, PVector v1, PVector v2) {
    this.d = d;
    vi[0] = d.addV(v0);
    vi[1] = d.addV(v1);
    vi[2] = d.addV(v2);
  }

  PVector getV(int idx) {
    return d.getV(idx);
  }

  PVector v0() {
    return getV(vi[0]);
  }

  PVector v1() {
    return getV(vi[1]);
  }

  PVector v2() {
    return getV(vi[2]);
  }

  boolean isInner(PVector p) {
    PVector p0 = new PVector(v0().x - p.x, v0().y - p.y);
    PVector p1 = new PVector(v1().x - p.x, v1().y - p.y);
    PVector p2 = new PVector(v2().x - p.x, v2().y - p.y);

    float a = 0.0f;
    a += PVector.angleBetween(p0, p1) * (p0.cross(p1).z >= 0.0f ? 1 : -1);
    a += PVector.angleBetween(p1, p2) * (p1.cross(p2).z >= 0.0f ? 1 : -1);
    a += PVector.angleBetween(p2, p0) * (p2.cross(p0).z >= 0.0f ? 1 : -1);

    if (abs(a) > 0.01f) return true;
    return false;
  }

  boolean hasVI(int idx) {
    if (vi[0] == idx || vi[1] == idx || vi[2] == idx) return true;
    return false;
  }

  boolean hasVI(int vi0, int vi1) {
    if (hasVI(vi0) == true && hasVI(vi1) == true) return true;
    return false;
  }

  int getVI_exclude(int vi0, int vi1) {
    if (vi0 == vi[0]) {
      if (vi1 == vi[1]) {
        return vi[2];
      } else if (vi1 == vi[2]) {
        return vi[1];
      }
    } else if (vi0 == vi[1]) {
      if (vi1 == vi[2]) {
        return vi[0];
      } else if (vi1 == vi[0]) {
        return vi[2];
      }
    } else if (vi0 == vi[2]) {
      if (vi1 == vi[0]) {
        return vi[1];
      } else if (vi1 == vi[1]) {
        return vi[0];
      }
    }
    return -1;
  }

  void draw() {
    line(v0().x, v0().y, v1().x, v1().y);
    line(v1().x, v1().y, v2().x, v2().y);
    line(v2().x, v2().y, v0().x, v0().y);
  }

  boolean equals(Triangle t) {
    if (t.vi[0] == this.vi[0] && t.vi[1] == this.vi[1] && t.vi[2] == this.vi[2]) return true;
    if (t.vi[0] == this.vi[1] && t.vi[1] == this.vi[2] && t.vi[2] == this.vi[0]) return true;
    if (t.vi[0] == this.vi[2] && t.vi[1] == this.vi[0] && t.vi[2] == this.vi[1]) return true;
    return false;
  }

  String toString() {
    return "tr:{0:" + vi[0] + ", 1:" + vi[1] + ", 2:" + vi[0] + "}";
  }
}

class TargetEdge {
  int vi0;
  int vi1;

  TargetEdge(int vi0, int vi1) {
    this.vi0 = vi0;
    this.vi1 = vi1;
  }
}

class DelaunayTriangulation {
  Vector<PVector> vertices = new Vector<PVector>();
  Vector<Triangle> triangles = new Vector<Triangle>();

  LinkedList<TargetEdge> edge_queue = new LinkedList<TargetEdge>();

  void DelaunayTriangulation() {
  }

  void clear() {
    vertices.clear();
    triangles.clear();
    edge_queue.clear();
  }

  boolean process(PVector [] src) {
    clear();
    if (src == null || src.length ==0 ) return false;

    initialize(src);
    for (int i = 0; i < src.length; ++i) {
      //println("progress=" + i + "/" + src.length);
      PVector v = src[i];
      appendPoint(v);
    }
    cleanup();

    return true;
  }

  void initialize(PVector [] src) {
    // 点群を外包する矩形を作成
    Rectangle r = createBoundingBox(src);

    // 矩形を内包する正三角形を作成
    PVector [] v = createEnvelopeTriangle(r);
    Triangle t = new Triangle(this, v[0], v[1], v[2]);
    triangles.add(t);
  }

  boolean appendPoint(PVector target_v) {
    if (isEqualPosition(target_v)) {
      // 同じ位置の点は追加しない
      println("DelaunayTriangulation.appendPoint() : error...isEqualPosition()==true");
      return false;
    }

    // 追加しようとしている点を内包している三角形を探す
    Triangle target_t = null;
    for (Triangle t : triangles) {
      if (t.isInner(target_v) == true) {
        target_t = t;
        break;
      }
    }
    if (target_t == null) {
      println("DelaunayTriangulation.appendPoint() : error...target_t==null");
      return false;
    }

    // 見つかった三角形を削除＆新たに三角形を3分割する
    removeT(target_t);

    int target_vi = addV(target_v);
    int vi0 = target_t.vi[0];
    int vi1 = target_t.vi[1];
    int vi2 = target_t.vi[2];

    Triangle t0 = new Triangle(this, target_vi, vi0, vi1);
    Triangle t1 = new Triangle(this, target_vi, vi1, vi2);
    Triangle t2 = new Triangle(this, target_vi, vi2, vi0);

    addT(t0);
    addT(t1);
    addT(t2);

    // メッシュの最適化
    addTargetEdge(vi0, vi1);
    addTargetEdge(vi1, vi2);
    addTargetEdge(vi2, vi0);

    while (edge_queue.size() > 0) {
      TargetEdge e = edge_queue.pop();
      meshOptimize(e.vi0, e.vi1);
    }

    return true;
  }

  void cleanup() {
    // TODO: trianglesからvi=0,1,2を含む含む三角形を削除する
    Iterator<Triangle> it = triangles.iterator();
    while (it.hasNext()) {
      Triangle t = it.next();
      if (t.hasVI(0) || t.hasVI(1) || t.hasVI(2)) {
        it.remove();
      }
    }

    // 一番初めの3点を削除する (vi=0, 1, 2)
    vertices.remove(0);
    vertices.remove(0);
    vertices.remove(0);

    // インデックスの再構築。頂点インデックスを全体を-3ずらす
    for (int i=0; i < triangles.size(); ++i) {
      Triangle t = triangles.get(i);
      t.vi[0] += -3;
      t.vi[1] += -3;
      t.vi[2] += -3;
    }
  }

  ////////////////////////////////////////////////////////////////////////////

  Rectangle createBoundingBox(PVector [] src) {
    float min_x = Float.MAX_VALUE;
    float max_x = Float.MIN_VALUE;
    float min_y = Float.MAX_VALUE;
    float max_y = Float.MIN_VALUE;

    for (PVector p : src) {
      if (min_x > p.x) min_x = p.x;
      if (max_x < p.x) max_x = p.x;
      if (min_y > p.y) min_y = p.y;
      if (max_y < p.y) max_y = p.y;
    }

    return new Rectangle(min_x, min_y, max_x - min_x, max_y - min_y);
  }

  PVector [] createEnvelopeTriangle(Rectangle rect) {
    // 矩形の外接円を作成
    PVector c = new PVector(rect.x + rect.w / 2.0f, rect.y + rect.h / 2.0f);
    float r = PVector.dist(c, rect.tl());

    // 内接円に対応する正三角形を作成
    PVector [] v = new PVector[3];

    v[0] = new PVector(c.x, c.y - 2 * r);
    v[1] = new PVector(c.x + sqrt(3.0) * r, c.y + r);
    v[2] = new PVector(c.x - sqrt(3.0) * r, c.y + r);

    return v;
  }

  void meshOptimize(int vi0, int vi1) {
    // 頂点を含む三角形を取り出す
    Triangle [] t = getT_by_VertexIndex(vi0, vi1);

    // 隣接する2つの三角形がなかった場合は処理しない 
    if (t == null || t.length != 2) return; 

    // flipping処理のメモ: 
    //   vi_a-vi0-vi1, vi_b-vi0-vi1の2つの三角形を想定
    //   vi_a, vi0, vi1の3点を通る円を描き、その中にvi_bが入っていた場合は
    //   三角形の辺vi0-vi1をvi_a-vi_bへつなぎなおす処理
    //   詳しくはこちら参照 → https://en.wikipedia.org/wiki/Delaunay_triangulation#Flip_algorithms
    //
    //  vi0 ---- vi_b     vi0 ---- vi_b
    //   |  \     |        |     /  |
    //   |   \    |   -->  |    /   |
    //   |    \   |        |   /    |
    //   |     \  |        |  /     |
    //  vi_a---- vi1      vi_a---- vi1
    //

    // vi0, vi1は2つの三角形で共有されている
    // それ以外の点を取得する
    int [] vi_o = new int[2];
    vi_o[0] = t[0].getVI_exclude(vi0, vi1);
    vi_o[1] = t[1].getVI_exclude(vi0, vi1);

    for (int i = 0; i < 2; ++i) {
      int vi_a = vi_o[i];
      int vi_b = vi_o[(i+1)%2];

      // vi_a, vi0, vi1で構成される円の中にvi_bが含まれるかどうかをチェック
      Circle c = new Circle(this, vi_a, vi0, vi1);

      // もし含まれる場合は、flipping処理を行う
      if (c.isInner(vi_b)) {
        // 既存の三角形を消す
        removeT(t[0]);
        removeT(t[1]);

        // 頂点を入れ替えた三角形を作成する
        Triangle t0 = new Triangle(this, vi0, vi_a, vi_b);
        addT(t0);

        Triangle t1 = new Triangle(this, vi1, vi_a, vi_b);
        addT(t1);

        // 入れ替えて生成された三角形のエッジをflipping調査対象に追加
        addTargetEdge(vi0, vi_a);
        addTargetEdge(vi0, vi_b);
        addTargetEdge(vi1, vi_a);
        addTargetEdge(vi1, vi_b);

        break;
      }
    }
  }

  ////////////////////////////////////////////////////////////////////////////

  int addV(PVector v) {
    vertices.add(v);
    return vertices.size() - 1; // 追加したインデックスを返す
  }

  PVector getV(int idx) {
    if (vertices.size() <= idx) {
      println("DelauneyTraiangulation.getV() : error : invalid idx=" + idx);
      return null;
    }
    return vertices.get(idx);
  }

  void addT(Triangle t) {
    triangles.add(t);
  }

  Triangle getT(int idx) {
    if (triangles.size() <= idx) {
      println("DelauneyTraiangulation.getT() : error : invalid idx=" + idx);
      return null;
    }

    return triangles.get(idx);
  }

  Triangle [] getT_by_VertexIndex(int vi0, int vi1) {
    List<Triangle> list = new ArrayList<Triangle>();

    for (int i = 0; i < triangles.size(); ++i) {
      Triangle t = triangles.get(i);
      if (t.hasVI(vi0, vi1) == true) {
        list.add(t);
      }
    }
    return list.toArray(new Triangle[list.size()]);
  }

  void removeT(Triangle target_t) {
    for (int i = 0; i < triangles.size(); ++i) {
      if (target_t.equals(getT(i))) {
        triangles.remove(i);
        break;
      }
    }
  }

  boolean isEqualPosition(PVector target) {
    for (PVector v : vertices) {
      if (v.x == target.x && v.y == target.y) return true;
    }
    return false;
  }

  void addTargetEdge(int vi0, int vi1) {
    edge_queue.add(new TargetEdge(vi0, vi1));
  }

  ////////////////////////////////////////////////////////////////////////

  void draw() {
    //noStroke();
    //fill(#440044);
    //for (Triangle t : triangles) {
    //  Circle c = new Circle(this, t.vi[0], t.vi[1], t.vi[2]);
    //  for (int i = 0; i < vertices.size(); ++i) {
    //    PVector v = vertices.get(i);
    //    if (c.isInner(v)) {
    //      c.draw();
    //    }
    //  }
    //}

    stroke(#00ff00);
    strokeWeight(1);
    for (Triangle t : triangles) {
      t.draw();
    }

    //Vector<Integer> inner_v = new Vector<Integer>();

    //stroke(#0000ff);
    //strokeWeight(1);
    //noFill();
    //for (Triangle t : triangles) {
    //  Circle c = new Circle(this, t.vi[0], t.vi[1], t.vi[2]);
    //  c.draw();
    //  for (int i = 0; i < vertices.size(); ++i) {
    //    PVector v = vertices.get(i);
    //    if (c.isInner(v)) {
    //      inner_v.add(i);
    //    }
    //  }
    //}

    noStroke();
    ellipseMode(CENTER);
    for (int i = 0; i < vertices.size(); ++i) {
      PVector v = vertices.get(i);
      fill(#ff0000);
      ellipse(v.x, v.y, 3, 3);
    }
  }
}
