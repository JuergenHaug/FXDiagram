package de.fxdiagram.core.services;

import com.google.common.base.Objects;
import com.google.common.collect.BiMap;
import com.google.common.collect.HashBiMap;
import de.fxdiagram.annotations.properties.ModelNode;
import de.fxdiagram.core.model.DomainObjectDescriptor;
import de.fxdiagram.core.model.DomainObjectProvider;
import de.fxdiagram.core.model.ModelElementImpl;
import de.fxdiagram.core.services.ResourceDescriptor;
import de.fxdiagram.core.services.ResourceHandle;
import org.eclipse.xtext.xbase.lib.Exceptions;

@ModelNode
@SuppressWarnings("all")
public class ResourceProvider implements DomainObjectProvider {
  private BiMap<String,ClassLoader> classLoaderMap = HashBiMap.<String, ClassLoader>create();
  
  private ClassLoader defaultClassLoader;
  
  public ResourceProvider(final ClassLoader defaultClassLoader) {
    this.defaultClassLoader = defaultClassLoader;
  }
  
  public ClassLoader addClassLoader(final String id, final ClassLoader classLoader) {
    return this.classLoaderMap.put(id, classLoader);
  }
  
  protected ClassLoader getClassLoader(final String id) {
    ClassLoader _xifexpression = null;
    boolean _equals = Objects.equal(id, null);
    if (_equals) {
      _xifexpression = this.defaultClassLoader;
    } else {
      _xifexpression = this.classLoaderMap.get(id);
    }
    return _xifexpression;
  }
  
  protected String getClassLoaderId(final ClassLoader classLoader) {
    BiMap<ClassLoader,String> _inverse = this.classLoaderMap.inverse();
    return _inverse.get(classLoader);
  }
  
  public Object resolveDomainObject(final DomainObjectDescriptor descriptor) {
    ResourceHandle _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (descriptor instanceof ResourceDescriptor) {
        _matched=true;
        _switchResult = this.resolveResourceHandle(((ResourceDescriptor)descriptor));
      }
    }
    if (!_matched) {
      throw new IllegalArgumentException(("Cannot handle " + descriptor));
    }
    return _switchResult;
  }
  
  protected ResourceHandle resolveResourceHandle(final ResourceDescriptor description) {
    String _name = description.getName();
    Class<?> _loadClass = this.loadClass(description);
    String _relativePath = description.getRelativePath();
    return new ResourceHandle(_name, _loadClass, _relativePath);
  }
  
  protected Class<?> loadClass(final ResourceDescriptor description) {
    try {
      String _classLoaderId = description.getClassLoaderId();
      ClassLoader _classLoader = this.getClassLoader(_classLoaderId);
      String _className = description.getClassName();
      return _classLoader.loadClass(_className);
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  public DomainObjectDescriptor createDescriptor(final Object domainObject) {
    ResourceDescriptor _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (domainObject instanceof ResourceHandle) {
        _matched=true;
        _switchResult = this.createResourceDescriptor(((ResourceHandle)domainObject));
      }
    }
    if (!_matched) {
      throw new IllegalArgumentException(("Cannot handle " + domainObject));
    }
    return _switchResult;
  }
  
  public ResourceDescriptor createResourceDescriptor(final ResourceHandle object) {
    Class<?> _context = object.getContext();
    ClassLoader _classLoader = _context.getClassLoader();
    String _classLoaderId = this.getClassLoaderId(_classLoader);
    Class<?> _context_1 = object.getContext();
    String _canonicalName = _context_1.getCanonicalName();
    String _relativePath = object.getRelativePath();
    String _name = object.getName();
    return new ResourceDescriptor(_classLoaderId, _canonicalName, _relativePath, _name, this);
  }
  
  /**
   * Automatically generated by @ModelNode. Needed for deserialization.
   */
  public ResourceProvider() {
  }
  
  public void populate(final ModelElementImpl modelElement) {
    
  }
}