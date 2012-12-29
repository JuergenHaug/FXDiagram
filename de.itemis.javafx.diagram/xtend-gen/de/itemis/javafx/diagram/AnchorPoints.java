package de.itemis.javafx.diagram;

import de.itemis.javafx.diagram.Extensions;
import de.itemis.javafx.diagram.XNode;
import java.util.ArrayList;
import java.util.List;
import javafx.beans.binding.ObjectBinding;
import javafx.beans.property.DoubleProperty;
import javafx.beans.property.ReadOnlyObjectProperty;
import javafx.geometry.Bounds;
import javafx.geometry.Point2D;
import javafx.scene.Node;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;

@SuppressWarnings("all")
public class AnchorPoints extends ObjectBinding<List<Point2D>> {
  private XNode host;
  
  public AnchorPoints(final XNode host) {
    DoubleProperty _layoutXProperty = host.layoutXProperty();
    DoubleProperty _layoutYProperty = host.layoutYProperty();
    Node _node = host.getNode();
    ReadOnlyObjectProperty<Bounds> _boundsInLocalProperty = _node.boundsInLocalProperty();
    this.bind(_layoutXProperty, _layoutYProperty, _boundsInLocalProperty);
    this.host = host;
  }
  
  protected List<Point2D> computeValue() {
    ArrayList<Point2D> _xblockexpression = null;
    {
      Node _node = this.host==null?(Node)null:this.host.getNode();
      Node _node_1 = this.host.getNode();
      Bounds _boundsInLocal = _node_1.getBoundsInLocal();
      final Bounds bounds = _node==null?(Bounds)null:Extensions.localToRoot(_node, _boundsInLocal);
      ArrayList<Point2D> _xifexpression = null;
      boolean _notEquals = ObjectExtensions.operator_notEquals(bounds, null);
      if (_notEquals) {
        ArrayList<Point2D> _xblockexpression_1 = null;
        {
          double _maxX = bounds.getMaxX();
          double _minX = bounds.getMinX();
          double _plus = (_maxX + _minX);
          final double middleX = (_plus / 2);
          double _maxY = bounds.getMaxY();
          double _minY = bounds.getMinY();
          double _plus_1 = (_maxY + _minY);
          final double middleY = (_plus_1 / 2);
          double _minX_1 = bounds.getMinX();
          Point2D _point2D = new Point2D(_minX_1, middleY);
          double _maxX_1 = bounds.getMaxX();
          Point2D _point2D_1 = new Point2D(_maxX_1, middleY);
          double _minY_1 = bounds.getMinY();
          Point2D _point2D_2 = new Point2D(middleX, _minY_1);
          double _maxY_1 = bounds.getMaxY();
          Point2D _point2D_3 = new Point2D(middleX, _maxY_1);
          ArrayList<Point2D> _newArrayList = CollectionLiterals.<Point2D>newArrayList(_point2D, _point2D_1, _point2D_2, _point2D_3);
          _xblockexpression_1 = (_newArrayList);
        }
        _xifexpression = _xblockexpression_1;
      }
      _xblockexpression = (_xifexpression);
    }
    return _xblockexpression;
  }
}
