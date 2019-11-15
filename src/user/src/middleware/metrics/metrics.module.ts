
import { Module } from '@nestjs/common';
import { PromModule, MetricType } from '@digikare/nestjs-prom';
import { APP } from '../../config/constants';

const promRoot = PromModule.forRoot({
  withDefaultController: true,
  useHttpCounterMiddleware: true,
  defaultLabels: {
    app: `${APP.NAME}_${APP.VERSION}`,
  },
});

const promMetric = PromModule.forMetrics([
  {
    type: MetricType.Counter,
    configuration: {
      name: 'root_counter',
      help: `Root ${APP.NAME} application counter`,
    },
  },
  {
    type: MetricType.Histogram,
    configuration: {
      name: 'root_histogram',
      help: `Root ${APP.NAME} application histogram`,
    },
  },
]);

@Module({
  imports: [promRoot, promMetric],
  exports: [promRoot, promMetric],
})
export class MetricsModule { }
