class ComponentRegistry {
  private static instance: ComponentRegistry;
  private components: Map<string, React.ComponentType<any>> = new Map();

  static getInstance(): ComponentRegistry {
    if (!ComponentRegistry.instance) {
      ComponentRegistry.instance = new ComponentRegistry();
    }
    return ComponentRegistry.instance;
  }

  register(id: string, component: React.ComponentType<any>): void {
    this.components.set(id, component);
  }

  get(id: string): React.ComponentType<any> | undefined {
    return this.components.get(id);
  }

  getAll(): Map<string, React.ComponentType<any>> {
    return this.components;
  }
}

export default ComponentRegistry.getInstance();
