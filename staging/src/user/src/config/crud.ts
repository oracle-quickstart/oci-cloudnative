import { CrudConfigService } from '@nestjsx/crud';

/**
 * Configure CRUD defaults
 */
CrudConfigService.load({
  query: {
    limit: 25,
    maxLimit: 250,
  },
  routes: {
    // exclude /bulk
    exclude: ['createManyBase'],
  },
  params: {
    id: {
      field: 'id',
      type: 'uuid',
      primary: true,
    },
  },
});
