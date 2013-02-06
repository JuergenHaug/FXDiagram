package de.itemis.javafx.diagram;

import de.itemis.javafx.diagram.XAbstractDiagram;
import de.itemis.javafx.diagram.tools.DiagramGestureTool;
import de.itemis.javafx.diagram.tools.SelectionTool;
import javafx.beans.property.DoubleProperty;
import javafx.beans.property.SimpleDoubleProperty;
import javafx.collections.ObservableList;
import javafx.scene.Group;
import javafx.scene.Node;
import org.eclipse.xtext.xbase.lib.Functions.Function0;

@SuppressWarnings("all")
public class XRootDiagram extends XAbstractDiagram {
  private Group nodeLayer = new Function0<Group>() {
    public Group apply() {
      Group _group = new Group();
      return _group;
    }
  }.apply();
  
  private Group connectionLayer = new Function0<Group>() {
    public Group apply() {
      Group _group = new Group();
      return _group;
    }
  }.apply();
  
  private Group buttonLayer = new Function0<Group>() {
    public Group apply() {
      Group _group = new Group();
      return _group;
    }
  }.apply();
  
  private DoubleProperty scaleProperty = new Function0<DoubleProperty>() {
    public DoubleProperty apply() {
      SimpleDoubleProperty _simpleDoubleProperty = new SimpleDoubleProperty(1.0);
      return _simpleDoubleProperty;
    }
  }.apply();
  
  public XRootDiagram() {
    ObservableList<Node> _children = this.getChildren();
    _children.add(this.nodeLayer);
    ObservableList<Node> _children_1 = this.getChildren();
    _children_1.add(this.connectionLayer);
    ObservableList<Node> _children_2 = this.getChildren();
    _children_2.add(this.buttonLayer);
  }
  
  public void doActivate() {
    super.doActivate();
    new DiagramGestureTool(this);
    new SelectionTool(this);
  }
  
  public Group getNodeLayer() {
    return this.nodeLayer;
  }
  
  public Group getConnectionLayer() {
    return this.connectionLayer;
  }
  
  public Group getButtonLayer() {
    return this.buttonLayer;
  }
  
  public DoubleProperty getScaleProperty() {
    return this.scaleProperty;
  }
}
