grade.sh
测试

pts=10
quick_check 'check_slub' \
    'check_slub() succeeded!' \
    'SLUB: Basic allocation test passed' \
    'SLUB: Multi-cache test passed'
