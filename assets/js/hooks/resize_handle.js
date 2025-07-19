export default {
  mounted() {
    let isResizing = false;
    let startX = 0;
    let startWidth = 0;
    let container = null;

    const handleMouseDown = (e) => {
      isResizing = true;
      startX = e.clientX;
      container = this.el.closest('.flex');
      if (container) {
        startWidth = container.getBoundingClientRect().width;
      }
      
      document.addEventListener('mousemove', handleMouseMove);
      document.addEventListener('mouseup', handleMouseUp);
      document.body.style.cursor = 'col-resize';
      document.body.style.userSelect = 'none';
      
      e.preventDefault();
    };

    const handleMouseMove = (e) => {
      if (!isResizing || !container) return;
      
      const deltaX = e.clientX - startX;
      const containerWidth = container.getBoundingClientRect().width;
      const newSplitPercentage = Math.round(((startWidth * 0.5 + deltaX) / containerWidth) * 100);
      
      // Constrain between 20% and 80%
      const constrainedSplit = Math.max(20, Math.min(80, newSplitPercentage));
      
      this.pushEvent('resize_panel', { split: constrainedSplit.toString() });
    };

    const handleMouseUp = () => {
      isResizing = false;
      document.removeEventListener('mousemove', handleMouseMove);
      document.removeEventListener('mouseup', handleMouseUp);
      document.body.style.cursor = '';
      document.body.style.userSelect = '';
    };

    this.el.addEventListener('mousedown', handleMouseDown);
    
    // Cleanup on destroy
    this.handleEvent = (event, callback) => {
      if (event === 'destroy') {
        this.el.removeEventListener('mousedown', handleMouseDown);
        document.removeEventListener('mousemove', handleMouseMove);
        document.removeEventListener('mouseup', handleMouseUp);
      }
    };
  }
};